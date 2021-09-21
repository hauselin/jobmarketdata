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


# years_postdoc
d0[, sort(unique(years_postdoc))]

# n_first_author
d0[, sort(unique(n_first_author))]

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

# remove duplicattes
d0 <- distinct(d0)
d0%>%View()

#datasummary_skim(d0)

#fwrite(d0, "../data/clean/data_cleaned.csv")
