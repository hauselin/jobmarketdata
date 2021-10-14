rm(list = ls())
library(data.table); library(tidyverse); library(modelsummary)

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

# research area
d0[, sort(unique(research_area))]

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

# years_graduate_student
d0[, sort(unique(years_graduate_student))]

# n_classes_taught
d0[, sort(unique(n_classes_taught))]%>%sort()
d0[n_classes_taught > 50, .(age, n_classes_taught, career_stage)]
d0[n_classes_taught > 400, n_classes_taught := NA]

# years_postdoc
d0[, sort(unique(years_postdoc))]

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

d0[, citations_total := as.numeric(citations_total)]
d0[, citations_year := as.numeric(citations_year)]
d0[citations_total == 99999999999, citations_total := NA]
d0[citations_year == 9999999999999, citations_year := NA]
d0[citations_year == 19500, citations_year := NA]
#d0[, sort(unique(citations_year))]%>%View


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

d0[, unique(research_area)]

glimpse(d0)

# home_institution




# remove duplicattes
d0 <- distinct(d0)

#datasummary_skim(d0)

#fwrite(d0, "../data/clean/data_cleaned.csv")
