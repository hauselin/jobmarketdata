
rm(list = ls())
library(data.table); library(tidyverse); library(stringr); library(readxl)
"../data/raw/Job Market Survey 2020.xlsx"

df_2020 <- setDT(read_excel("../data/raw/Job Market Survey 2020.xlsx"))
df_2020[, year := "2019-2020"]
df_2021 <- setDT(read_excel("../data/raw/PsychJobMarket (7.20.21).xlsx"))
df_2021[, year := "2018-2019"]



d2020 <- data.table(column = names(df_2020), dataID = 2020)
d2020[, N := 1:.N]
d2021 <- data.table(column = names(df_2021), dataID = 2021)
d2021[, N := 1:.N]

dColumnNames <- bind_rows(d2020, d2021)%>%arrange(column)%>%data.table()
dColumnNames[, .N, by = column][N == 1]

dColumnNames[, newColumn := gsub(x = newColumn, pattern = "2019-2020", replacement = "XXXX")]
dColumnNames[, newColumn := gsub(x = newColumn, pattern = "2018-2019", replacement = "XXXX")]
dColumnNames[, newColumn := gsub(x = newColumn, pattern = "2018", replacement = "XXXX")]
dColumnNames[, newColumn := gsub(x = newColumn, pattern = "2019", replacement = "XXXX")]

dColumnNames[, .N, by = newColumn][N == 1]
distinct_Columns <- distinct(dColumnNames[, .(newColumn)])
#fwrite(x = distinct_Columns, file = "../data/data_key.csv")
key <- fread("../data/data_key.csv")


new_columns <- left_join(dColumnNames, key[, .(newColumn = value, key)])%>%arrange(dataID, N)
View(new_columns)


new_columns[dataID == 2020, key]
df_2020%>%dim()
setnames(x = df_2020, new_columns[dataID == 2020, key])
glimpse(df_2020)


new_columns[dataID == 2021, ]%>%dim()
df_2021%>%dim()

setnames(x = df_2021, new_columns[dataID == 2021, key])
glimpse(df_2021)


df_2020$age
df_2021$age%>%table()

df_2021[age == "Male", age := NA]
df_2021[age == "999", age := NA]
df_2021[age == "9999", age := NA]

df_2021$age <- as.numeric(df_2021$age)

df_2020$citations_total%>%table()
df_2020$citations_total <- as.numeric(df_2020$citations_total)

df1 <- bind_rows(df_2020, df_2021)%>%data.table()

glimpse(df1)


df1[, date := str_sub(date, start = 1, end = 10)]

glimpse(df1)
df1[, unique(gender)]
df1[gender == "Option 1", gender:= NA]

df1[, unique(covid_job_search_impact)]
df1[covid_job_search_impact == "No", covid_job_search_impact := "0"]
df1[covid_job_search_impact == "Unsure/Sort of/Maybe", covid_job_search_impact := "0.5"]
df1[covid_job_search_impact == "Yes", covid_job_search_impact := "1"]
df1[, covid_job_search_impact := as.numeric(covid_job_search_impact)]

df1[, unique(permission)]


mask <- df1[, summarize_all(.SD, is.numeric)]
mask <- t(mask)[, 1] 
c <- names(mask[mask])

df2 <- copy(df1)

df2[, (c) := lapply(.SD, function(x) ifelse(x == 99999999, NA, x)), .SDcols=c]
df2[, (c) := lapply(.SD, function(x) ifelse(x == 9999999, NA, x)), .SDcols=c]

df2[, (c) := lapply(.SD, function(x) ifelse(x == 999999, NA, x)), .SDcols=c]
df2[, (c) := lapply(.SD, function(x) ifelse(x == 99999, NA, x)), .SDcols=c]

df2[, (c) := lapply(.SD, function(x) ifelse(x == 9999, NA, x)), .SDcols=c]
df2[, (c) := lapply(.SD, function(x) ifelse(x == 999, NA, x)), .SDcols=c]
df2[, (c) := lapply(.SD, function(x) ifelse(x == 99, NA, x)), .SDcols=c]

df2%>%summary
df2[n_offers_research > 30, n_offers_research := NA]

df2[, unique(ethnicity)]%>%sort()

fwrite(x = df2, file = '../data/clean/data_merged.csv')
glimpse(df1)

df2[, max(n_apply_tenure, na.rm=T)]

ggplot(df2[], aes(n_apply_tenure, n_interview_research_final)) + 
    geom_jitter() + 
    geom_smooth(formula = y ~ x, method = 'lm')

ggplot(df2[], aes(n_apply_tenure, n_offers_research)) + 
    geom_jitter() + 
    geom_smooth(formula = y ~ x, method = 'lm')


df2[n_offers_research == 8, ]%>%View
