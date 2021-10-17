rm(list = ls())
library(data.table); library(tidyverse); library(modelsummary); library(tools)

d0 <- fread("../data/clean/data_merged.csv")
d0
glimpse(d0)

# date
d0[, unique(date)] %>% sort()

# career stage
d0[, sort(unique(career_stage))]
d0[career_stage == "Currently in research admin/management at a university, after 3 years of postdocs", career_stage := "Admin"]
d0[career_stage == "research director at an academic center", career_stage := "Admin"]
d0[career_stage == "Independet/visiting researcher", career_stage := "Visiting professor/researcher"]
d0[career_stage == "visiting assistant professor (teaching and research)", career_stage := "Visiting professor/researcher"]
d0[career_stage == "One year visiting assistant position predominantly teaching responsibilities", career_stage := "Visiting professor/researcher"]
d0[career_stage == "Unemployed, searching for job after 3 year Postdoc", career_stage := "I'm not in academia"]
d0[career_stage == "Non-tenure track teaching & working in industry", career_stage := "Non-tenure-track teaching faculty"]
d0[career_stage == 'I am an ""entrepreneurial academic"" funded through consultancy and part-time academic positions', career_stage := "I'm not in academia"]
d0[career_stage == "Non-tecnure track teaching & working in industry", career_stage := "Non-tenure-track teaching faculty"]
d0[career_stage == "Taught as Visiting Professor in Fall 2019; Resigned due to long commute", career_stage := "I'm not in academia"]
d0[career_stage == "Research Scientist", career_stage := "Researcher/research scientist"]
d0[career_stage == "Statistician at a medical school", career_stage := "Researcher/research scientist"]
d0[career_stage == "Clinical researcher at a hospital", career_stage := "Researcher/research scientist"]
d0[career_stage == 'Government + adjuncting', career_stage := "I'm not in academia"]
d0[career_stage == 'Non-tenure track, but T&R position (Not in North America)', career_stage := "Non-tenure-track research faculty"]
d0[career_stage == 'Tenured researcher', career_stage := "Senior professor (tenured) or equivalent"]
d0[career_stage == 'Junior professor (tenure track but untenured) or equivalent', career_stage := "Junior professor (tenure track but untenured)"]
# d0[, .N, keyby = .(career_stage)][order(N)] %>% View()

# research_area
d0[, unique( research_area)]%>%sort()
ra <- d0[, research_area]
ra <- paste(ra, collapse = ";")
ra <- str_split(string = ra, pattern = ";")
ra <- ra[[1]]
ra <- data.table(table(ra))%>%arrange(N, ra)
ra[, ra_recoded := ""]
ra[ra == "cognitive modeling", ra_recoded := "Other"]
ra[grepl(pattern = 'commun', x = ra, ignore.case = T), ra_recoded := "Community"]
ra[grepl(pattern = 'compa', x = ra, ignore.case = T), ra_recoded := "Comparative"]
ra[ra %in% c('Consumer behavior', "computational social science", "sociology", "Labels are bad for science."), ra_recoded := "Other"]
ra[grepl(pattern = "foren", x = ra, ignore.case = T), ra_recoded  := "Forensic"]
ra[grepl(pattern = 'clin', x = ra, ignore.case = T) & !ra_recoded %in% c("Forensic"), ra_recoded := "Clinical & Counselling"]
ra[grepl(pattern = 'coun', x = ra, ignore.case = T), ra_recoded := "Clinical & Counselling"]
ra[grepl(pattern = 'health', x = ra, ignore.case = T) & ra_recoded != "Clinical & Counselling", ra_recoded := "Health"]
ra[grepl(pattern = 'soc', x = ra, ignore.case = T) & ra_recoded == "", ra_recoded := "Social & Personality"]
ra[grepl(pattern = "Schoo", x = ra, ignore.case = T), ra_recoded := "Education"]
ra[grepl(pattern = "cog", x = ra, ignore.case = T) & ra_recoded != "Other", ra_recoded := "Cognitive"]
ra[N < 4 & ra_recoded == "", ra_recoded := "Other"]
ra[ra_recoded == "", ra_recoded := ra]
ra[, ]%>%arrange(N, ra)

unique_ras <- ra[, ra]
i <- 1
for (i in 1:nrow(d0)) {
   x <- d0[i, research_area]
   ras <- str_split(string = x, pattern = ";")[[1]]
   mask <- unique_ras %in% ras
   recoded <- paste0(ra[mask, ra_recoded], collapse= ",")
   print(recoded)
   d0[i, research_area := recoded]
}


# institution_country
d0[, sort(unique(institution_country))]
d0[institution_country %in% c("-", ".", "Not applicable", "Prefer Not to Share", "xxx", "Y", "Betelgeuse", "Wakanda", "Wishland", "unemployed", "No institution really", "No home institution (I'm unemployed since my PhD defense)", "JAMJAMISTAN", "discworld", "Narnia", "Ausy", "Disney", "Europe", "Starland"), institution_country := NA]
d0[institution_country %in% c("U.S", "U.S.", "U.S.A", "us", "US", "USA", "Usa", "usa", "Us", "United State", "United States of America", "United States", "Unites State", "United States (USA)", "Unites States", "United State of America", "Temple University", "U.S.A."), institution_country := "USA"]
d0[institution_country %in% c("Uk", "United Kingdom", "UK (but not really at an \"\"institution\"\" - see above)", "England"), institution_country := "UK"]
d0[institution_country == "I did my PhD in Switzerland, now in Finland", institution_country := "Finland"]
d0[institution_country == "france", institution_country := "France"]
d0[institution_country == "french", institution_country := "France"]
d0[institution_country == "French", institution_country := "France"]
d0[institution_country == "germany", institution_country := "Germany"]
d0[institution_country == "canada", institution_country := "Canada"]
d0[institution_country == "sweden", institution_country := "Sweden"]
d0[institution_country == "Netherlands", institution_country := "The Netherlands"]
d0[, sort(unique(institution_country))]

# gender
d0[, sort(unique(gender))]
d0[gender == "", gender := NA]
d0[gender == "Prefer not to say", gender := NA]
#d0[, .N, keyby = .(gender)][order(N)] %>% View()

# age
d0[, unique(age)] %>% sort()
d0[age == 1985, age := 2020 - 1985]

# ethnicity 
d0[, unique(ethnicity)]%>% sort()
d0[, ethnicity := tolower(ethnicity)]
d0[, ethnicity := str_squish(ethnicity)]
d0[, ethnicity := str_trim(ethnicity)]
d0[, ethnicity := gsub(x = ethnicity, pattern = "/", replacement = " ", fixed = T)]
d0[, ethnicity := gsub(x = ethnicity, pattern = ",", replacement = " ", fixed = T)]
d0[, ethnicity := gsub(x = ethnicity, pattern = "-", replacement = " ", fixed = T)]
d0[, ethnicity := gsub(x = ethnicity, pattern = ")", replacement = " ", fixed = T)]
d0[, ethnicity := gsub(x = ethnicity, pattern = "(", replacement = " ", fixed = T)]
d0[, ethnicity := gsub(x = ethnicity, pattern = "&", replacement = " ", fixed = T)]
d0[, ethnicity := gsub(x = ethnicity, pattern = "+", replacement = " ", fixed = T)]
d0[, ethnicity := gsub(x = ethnicity, pattern = "?", replacement = " ", fixed = T)]
d0[, ethnicity := gsub(x = ethnicity, pattern = "?", replacement = " ", fixed = T)]
d0[, ethnicity := str_squish(ethnicity)]
d0[, ethnicity := str_trim(ethnicity)]

d0[grepl(pattern = 'cauc', x = ethnicity, fixed = T), ethnicity := "White"]
d0[ethnicity == "white", ethnicity := "White"]
d0[ethnicity %in% c("white native american","black latino", "black white", "biracial", "asian hawaiian white", "white middle eastern"), ethnicity := "Mixed"]
d0[grepl(pattern = 'europ', x = ethnicity, fixed = T) & !grepl(pattern = "middle", x = ethnicity, fixed=T), ethnicity := "White"]
d0[ethnicity %in% c("african american", "black", "nigerian", "guyanese"), ethnicity := "Black"]
d0[ethnicity %in% c("whote", "wasp", 'w', "causacian", "turkish", "greek", "canadian", "american", "british", "german", "italian", "belgian", "hungarian"), ethnicity := "White"]
d0[grepl(pattern = 'mix', x = ethnicity), ethnicity := "Mixed"]
d0[grepl(pattern = 'mul', x = ethnicity), ethnicity := "Mixed"]
d0[grepl(pattern = 'half', x = ethnicity), ethnicity := "Mixed"]
d0[grepl(pattern = 'and', x = ethnicity), ethnicity := "Mixed"]
d0[grepl(pattern = 'jew', x = ethnicity), ethnicity := "White"]
d0[grepl(pattern = 'white', x = ethnicity, fixed = T) & grepl(pattern = "non", x = ethnicity, fixed=T), ethnicity := "White"]
d0[grepl(pattern = 'white', x = ethnicity, fixed = T) & grepl(pattern = "not", x = ethnicity, fixed=T), ethnicity := "White"]
d0[grepl(pattern = 'white', x = ethnicity, fixed = T) & grepl(pattern = "hisp", x = ethnicity, fixed=T), ethnicity := "Mixed" ]
d0[grepl(pattern = 'white', x = ethnicity, fixed = T) & grepl(pattern = "lat", x = ethnicity, fixed=T), ethnicity := "Mixed"]
d0[grepl(pattern = 'not h', x = ethnicity), ethnicity := "White"]
d0[grepl(pattern = 'not l', x = ethnicity), ethnicity := "White"]
d0[grepl(pattern = 'non h', x = ethnicity), ethnicity := "White"]
d0[grepl(pattern = 'non l', x = ethnicity), ethnicity := "White"]
d0[grepl(pattern = 'lat', x = ethnicity), ethnicity := "Latino/Hispanic"]
d0[grepl(pattern = 'mex', x = ethnicity), ethnicity := "Latino/Hispanic"]
d0[ethnicity == "hispanic", ethnicity := "Latino/Hispanic"]
d0[ethnicity == "chicano", ethnicity := "Latino/Hispanic"]
d0[grepl(pattern = 'pref', x = ethnicity), ethnicity := NA]
d0[grepl(pattern = 'chin', x = ethnicity), ethnicity := "Asian"]
d0[grepl(pattern = 'white', x = ethnicity, fixed = T) 
   & !grepl(pattern = "hisp", x = ethnicity, fixed=T)
   & !grepl(pattern = "lat", x = ethnicity, fixed = T) 
   & !grepl(pattern = "mix", x = ethnicity, fixed = T)
   & !grepl(pattern = "mid", x = ethnicity, fixed = T)
   & !grepl(pattern = "native", x = ethnicity, fixed = T)
   & !grepl(pattern = "asian", x = ethnicity, fixed = T)
   & !grepl(pattern = "mexican", x = ethnicity, fixed = T)
   & !grepl(pattern = "black", x = ethnicity, fixed = T),
   ethnicity := "White"]
d0[grepl(pattern = 'asian', x = ethnicity), ethnicity := "Asian"]
d0[ethnicity %in% c('armenian'), ethnicity := "Other"]
d0[ethnicity %in% c("woman of color donâ€™t want to specify further", "bipoc","48", "999", "", "sfsdf"), ethnicity := NA]
d0[ethnicity %in% c("taiwanese", "japanese", "indian", "west indian"), ethnicity := "Asian"]
d0[grepl(pattern = 'mid', x = ethnicity), ethnicity := "Middle Eastern"]
d0[grepl(pattern = 'nat', x = ethnicity), ethnicity := "Native American"]
d0[ethnicity %in% c("iranian", "mena"), ethnicity := "Middle Eastern"]
d0[grepl(pattern = 'nat', x = ethnicity), ethnicity]
d0[, sort(unique(ethnicity))]

# home_institution
d0[home_institution %in% c("", "School in the University of Texas System", "999", "..", "-", "None", "White", "xx", "A school in the mid-Atlantic", "xxxx", "A public university in the Southeastern US", "sdfsdf", "xxx",
                         "unemployed",  "No home institution (I'm unemployed since my PhD defense)", "Small liberal arts college", "CNRS", 'Rather not say', "UiO", "A tech startup",  "Large public research university in the south", "Do not wish to answer","UW" , "UK", "n/a (see above)", "R2 state university", "R1 Southeastern US", "This answer is for the next question, as only a number is accepted there: 4 years on PhD, and 2 years on MSc. I'm not sure what 'graduate student' refers to"), 
                           home_institution := NA]


d0[grepl(pattern = "Harvar", x = home_institution, fixed = T), home_institution := "Harvard"]
d0[grepl(pattern = "Northea", x = home_institution, fixed = T), home_institution := "Northeastern"]
d0[grepl(pattern = "UC", x = home_institution, fixed = T) & home_institution != "MIT/UCSD", home_institution := "University of California"]
d0[grepl(pattern = "of Cali", x = home_institution, fixed = T) & home_institution != "St. Maryâ€™s College of California",  home_institution := "University of California" ]
d0[grepl(pattern = "ornia State", x = home_institution, fixed = T), home_institution  := "California State University"]
d0[grepl(pattern = "University of Maryland", x = home_institution, fixed = T), home_institution  := "University of Maryland"]
d0[grepl(pattern = "USC", x = home_institution, fixed = T), home_institution := "University of Southern California" ]
d0[grepl(pattern = "CUNY", x = home_institution, fixed = T), home_institution := "CUNY"]
d0[grepl(pattern = "Chic", x = home_institution, fixed = T),home_institution := "University of Chicago"]
d0[grepl(pattern = "Melb", x = home_institution, fixed = T),home_institution := "University of Melbourne"]
d0[grepl(pattern = "Toronto", x = home_institution, fixed = T),home_institution := "University of Toronto" ]
d0[grepl(pattern = "University of Tex", x = home_institution, fixed = T), home_institution := "University of Texas" ]
d0[grepl(pattern = "Lav", x = home_institution, fixed = T), home_institution := "Laval" ]
d0[grepl(pattern = "gov", x = home_institution, fixed = T), home_institution := "Government"]
d0[grepl(pattern = "Pitt", x = home_institution, fixed = T), home_institution := "University of Pittsburgh"]
d0[grepl(pattern = "Flor", x = home_institution, fixed = T), home_institution]
d0[home_institution == "Florida", home_institution := "University of Florida"]
d0[grepl(pattern = "UNC", x = home_institution, fixed = T), home_institution := "University of North Carolina"]
d0[grepl(pattern = "Caro", x = home_institution, fixed = T), home_institution := "University of North Carolina"]
d0[grepl(pattern = "Nev", x = home_institution, fixed = T), home_institution := "University of Nevada"]
d0[grepl(pattern = "UBC", x = home_institution, fixed = T), home_institution := "University of British Columbia"]
d0[grepl(pattern = "British", x = home_institution, fixed = T), home_institution ]
d0[grepl(pattern = "Wisc", x = home_institution, fixed = T), home_institution := "University of Wisconsin"]
d0[grepl(pattern = "wisc", x = home_institution, fixed = T), home_institution ]
d0[grepl(pattern = "Bemidji", x = home_institution, fixed = T), home_institution := "Bemidji State"]
d0[grepl(pattern = "NYU", x = home_institution, fixed = T), home_institution := "New York University"]
d0[grepl(pattern = "UVA", x = home_institution, fixed = T), home_institution := "University of Virginia"]
d0[grepl(pattern = "Virginia Commonwealth Univ", x = home_institution, fixed = T), home_institution := "Virginia Commonwealth University"]
d0[grepl(pattern = "University of Western Ont", x = home_institution, fixed = T), home_institution := "University of Western Ontario"]
d0[grepl(pattern = "Ox", x = home_institution, fixed = T), home_institution := "University of Oxford" ]
d0[grepl(pattern = "NIH", x = home_institution, fixed = T), home_institution := "National Institutes of Health" ]
d0[grepl(pattern = "Berk", x = home_institution, fixed = T), home_institution := "Berkeley" ]
d0[grepl(pattern = "Kent ", x = home_institution, fixed = T), home_institution := "Kent State" ]
d0[grepl(pattern = "UW", x = home_institution, fixed = T), home_institution := "University of Wisconsin" ]
d0[grepl(pattern = "Rutgers", x = home_institution, fixed = T), home_institution := "Rutgers" ]
d0[grepl(pattern = "Stony Brook University (PhD) ; Brown University (postdoc)", x = home_institution, fixed = T), home_institution := "Brown" ]
d0[grepl(pattern = "Mass", x = home_institution, fixed = T), home_institution := "University of Massachusetts" ]
d0[grepl(pattern = "UT", x = home_institution, fixed = T), home_institution := "University of Texas" ]
d0[home_institution == "Brock University (Canada)", home_institution := "Brock University" ]
d0[home_institution == "University of.North Texas", home_institution := "University of North Texas" ]
d0[home_institution == "Concordia University (Montreal)", home_institution := "Concordia University" ]
d0[home_institution == "University", home_institution := NA ]
d0[home_institution == "harvard medical school", home_institution := "Harvard"]
d0[home_institution == "Columbia University", home_institution := "Columbia"]
d0[home_institution == "Regina", home_institution := "University of Regina"]
d0[grepl(pattern = "Bowling", x = home_institution, fixed = T), home_institution := "Bowling Green State University"]
d0[grepl(pattern = "CSU", x = home_institution, fixed = T), home_institution := "California State University"]
d0[grepl(pattern = "Iowa State", x = home_institution, fixed = T), home_institution := "Iowa State University"]
d0[grepl(pattern = "Stanford", x = home_institution, fixed = T), home_institution := "Standford University"]
d0[grepl(pattern = "McGill", x = home_institution, fixed = T), home_institution := "McGill University"]
d0[grepl(pattern = "Duke", x = home_institution, fixed = T), home_institution := "Duke University"]
d0[grepl(pattern = "urham", x = home_institution, fixed = T), home_institution := "Durham University"]
d0[grepl(pattern = "Yale", x = home_institution, fixed = T), home_institution := "Yale University"]
unique(d0[grepl(pattern = "ton", x = home_institution, fixed = T), home_institution])
print(d0[, .N, by = .(home_institution)], 100)%>%arrange(home_institution)

# years_graduate_student
d0[, sort(unique(years_graduate_student))]

# n_classes_taught
d0[, sort(unique(n_classes_taught))]%>%sort()
d0[n_classes_taught > 50, .(age, n_classes_taught, career_stage)]
d0[n_classes_taught > 300, n_classes_taught := NA]

# years_postdoc
d0[, sort(unique(years_postdoc))]

# n_months_family_leave
d0[, sort(unique(n_months_family_leave))]


# n_first_author
d0[, sort(unique(n_first_author))]

# n_papers_published
d0[, sort(unique(n_papers_published))]


# permission
d0[, sort(unique(permission))]
d0[permission == "", permission := NA]
d0[permission != "Yes", permission := "No"]

# funding
d0[, sort(unique(funding))]
d0[funding == 99999999999, funding := NA]
d0[funding > 5000000, funding := NA]
d0[, sort(unique(funding))]

# h-index
d0[, sort(unique(h_index))]
d0[h_index == 999999999, h_index := NA]
d0[h_index == 10000, h_index := NA]
d0[, sort(unique(h_index))]

# citations
d0[, citations_total := as.numeric(citations_total)]
d0[, citations_year := as.numeric(citations_year)]
d0[citations_total == 99999999999, citations_total := NA]
d0[citations_year == 9999999999999, citations_year := NA]
d0[citations_year == 19500, citations_year := NA]
d0[, sort(unique(citations_year))]
d0[, sort(unique(citations_total))]

# highest_profile_journal
d0[, sort(unique(highest_profile_journal))]
d0[, highest_profile_journal := gsub(pattern = "\r", replacement = "@", x = highest_profile_journal), ]
d0[, highest_profile_journal := gsub(pattern = "\n", replacement = "@", x = highest_profile_journal), ]
d0[, highest_profile_journal := gsub(pattern = "@@", replacement = "@", x = highest_profile_journal), ]
d0[, highest_profile_journal := gsub(pattern = ",", replacement = "@", x = highest_profile_journal), ]
d0[, highest_profile_journal := gsub(pattern = ";", replacement = "@", x = highest_profile_journal), ]
d0[, highest_profile_journal := tolower(highest_profile_journal)]
d0[, highest_profile_journal := gsub(pattern = "tics", replacement = "trends in cognitive sciences", x = highest_profile_journal), ]

hpj <- d0[, highest_profile_journal]
hpj <- paste(hpj, collapse = "@")
hpj <- str_split(string = hpj, pattern = "@")
hpj <- hpj[[1]]%>%sort()%>%unique()
grep(pattern = ",", x = hpj, value = T)
comma_journals <- c("psychology, public policy, and law", "psychology, crime and law", "psychology, public policy, and law" , "psychology, public policy, and the law",
                    "psychology, public policy, and law",  "creativity, and the arts", "personality disorders: theory, research, and treatment", "personality disorders: theory, research & treatment ",
                    "personality disorders: theory, research, & treatment", "mind, brain, and education",  "journals of gerontology, series b", "journal of experimental psychology: learning, memory, and cognition",
                    "journal of experimental psychology: learning, memory, & cognition", "journal of experimental psychology: learning, memory & cognition", "cognitive, affective, & behavioral neuroscience",
                    "brain, behavior, and immunology" , " psychology, public policy & law", "attention, perception, & psychophysics")

for (i in comma_journals) {
   i
   i2 <- gsub(pattern = ",", x = i, replacement = "")
   d0[, highest_profile_journal := gsub(pattern = i, replacement = i2,x = highest_profile_journal)]
}


hpj <- d0[, highest_profile_journal]
hpj <- paste(hpj, collapse = "@")
hpj <- str_split(string = hpj, pattern = "@")
hpj <- hpj[[1]]%>%sort()%>%unique()
grep(pattern = ",", x = hpj, value = T)

d0[, highest_profile_journal := gsub(pattern = ",", replacement = "@", x = highest_profile_journal), ]
hpj <- paste(d0$highest_profile_journal, collapse = "@")
hpj <- str_split(string = hpj, pattern = "@")
hpj <- hpj[[1]]%>%sort()%>%unique()
hpj <- str_squish(hpj)%>%unique()

#fwrite(x = data.table(hpj), file = "../data/clean/hpj.csv")
hpj <- fread("../data/clean/hpj2.csv")
hpj
hpj[, hpj := gsub("(", "", hpj, fixed = TRUE)]
hpj[, hpj := gsub(")", "", hpj, fixed = TRUE)]

d0[, highest_profile_journal := gsub("(", "", highest_profile_journal, fixed = TRUE)]
d0[, highest_profile_journal := gsub(")", "", highest_profile_journal, fixed = TRUE)]
d0[, highest_profile_journal := gsub("@ ", "@", highest_profile_journal, fixed = TRUE)]

for (i in 1:nrow(d0)) {
   journals <- d0[i, highest_profile_journal]
   journals <- str_split(journals, '@')[[1]]
   new <- hpj[hpj %in% journals, hpj2]
   new <- toTitleCase(new)
   new <- new[new != ""]
   new <- gsub("Pnas", "PNAS", new)
   new <- gsub("Elife", "eLife", new)
   new <- gsub("Royal Society b", "Royal Society B", new)
   new <- gsub("Jama", "JAMA", new)
   new <- gsub("Npj", "NPJ", new)
   new <- gsub("Bmj", "BMF", new)
   new <- gsub("Ieee", "IEEE", new)
   new <- gsub("Neuroimage", "NeuroImage", new)
   new <- gsub("Bp:cnni", "BP:CNNI", new)
   new <- paste0(new, collapse = ",")
   
   # if (length(new) != length(journals)) {
   #    print(i)
   #    print(sort(journals))
   #    print(" ")
   #    print(sort(new))
   #    break
   # }
   d0[i, highest_profile_journal := new]
}
d0[, highest_profile_journal]

# n_months_family_leave
d0[, unique(n_months_family_leave)]%>%sort()
d0[n_months_family_leave > 30, .(age,career_stage, n_months_family_leave)]

# n_apply_tenure
d0[, unique(n_apply_tenure)]%>%sort()

# n_interview_research_initial
d0[, unique(n_interview_research_initial)]%>%sort()

# n_interview_research_final
d0[, unique(n_interview_research_final)]%>%sort()

# n_offers_research
d0[, unique(n_offers_research)]%>%sort()

# n_apply_teaching
d0[, unique(n_apply_teaching)]%>%sort()

# n_interview_teaching_initial
d0[, unique(n_interview_teaching_initial)]%>%sort()

# n_interview_teaching_final
d0[, unique(n_interview_teaching_final)]%>%sort()

# n_offers_teaching
d0[, unique(n_offers_teaching)]%>%sort()

# n_apply_nontenure
d0[, unique(n_apply_nontenure)]%>%sort()

# n_interviews_nontenure_intial
d0[, unique(n_interviews_nontenure_intial)]%>%sort()

# n_interviews_nontenure_final
d0[, unique(n_interviews_nontenure_final)]%>%sort()

# n_offers_nontenure
d0[, unique(n_offers_nontenure)]%>%sort()

# n_industry_apply
d0[, unique(n_industry_apply)]%>%sort()
d0[n_industry_apply > 100, .(age, career_stage, n_industry_apply)]

# n_interviews_industry_initial
d0[, unique(n_interviews_industry_initial)]%>%sort()

# n_interviews_industry_final
d0[, unique(n_interviews_industry_final)]%>%sort()

#  n_offers_industry
d0[, unique( n_offers_industry)]%>%sort()

#  covid_job_search_impact
d0[, unique( covid_job_search_impact)]%>%sort()

#  covid_job_search_impact_how
d0[, unique( covid_job_search_impact_how)]%>%sort()

#  job_market_comments
d0[, unique( job_market_comments)]%>%sort()

glimpse(d0)

# remove duplicattes
d0 <- distinct(d0)

# datasummary_skim(d0)

fwrite(d0, "../data/clean/data_cleaned.csv")
