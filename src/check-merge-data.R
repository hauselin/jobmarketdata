
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



