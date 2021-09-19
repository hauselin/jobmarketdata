rm(list = ls())
library(data.table); library(tidyverse)

d0 <- fread("../data/clean/data_merged.csv")
d0
glimpse(d0)

# date
d0[, unique(date)] %>% sort()

# age
d0[, unique(age)] %>% sort()
d0[age == 1985, age := 2020 - 1985]

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

# institution_country
d0[, sort(unique(institution_country))]
d0[institution_country %in% c("-", ".", "Not applicable", "Prefer Not to Share", "xxx", "Y", "Betelgeuse", "Wakanda", "Wishland", "unemployed", "No institution really", "No home institution (I'm unemployed since my PhD defense)", "JAMJAMISTAN", "discworld", "Narnia", "Ausy", "Disney", "Europe", "Starland"), institution_country := NA]
d0[institution_country %in% c("U.S", "U.S.", "U.S.A", "us", "US", "USA", "Usa", "usa", "Us", "United State", "United States of America", "United States", "Unites State", "United States (USA)", "Unites States", "United State of America", "Temple University", "U.S.A."), institution_country := "USA"]
d0[institution_country %in% c("Uk", "United Kingdom", "UK (but not really at an \"\"institution\"\" - see above)", "England"), institution_country := "UK"]
d0[institution_country == "I did my PhD in Switzerland, now in Finland", institution_country := "Finland"]
d0[institution_country == "france", institution_country := "France"]
d0[institution_country == "french", institution_country := "France"]
d0[institution_country == "germany", institution_country := "Germany"]
d0[institution_country == "canada", institution_country := "Canada"]
d0[institution_country == "sweden", institution_country := "Sweden"]
d0[institution_country == "Netherlands", institution_country := "The Netherlands"]
d0[, sort(unique(institution_country))]

# years_graduate_student
d0[, sort(unique(years_graduate_student))]

# gender
d0[, sort(unique(gender))]
d0[gender == "", gender := NA]
d0[gender == "Prefer not to say", gender := NA]

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

fwrite(d0, "../data/clean/data_cleaned.csv")
