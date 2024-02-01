# Libraries
library(tidyverse)
library(lubridate)
library(janitor)
library(arrow)

# Load data
data_files <- list.files("study/media/data/", full.names = TRUE)
data <- read_csv(
    data_files,
    col_types = cols(
        Source = col_character(),
        Article = col_character(),
        Published = col_character(),
        `Foregrounds recovery` = col_character(),
        `Qualified recovery` = col_character(),
        `Accurately reflects science` = col_character(),
        `Climate scepticism` = col_character(),
        `Identified political nature` = col_character(),
        `Headline qualifies recovery` = col_character(),
        `URL` = col_character(),
        `Read by` = col_character(),
        Comments = col_character()
    ))

# Recode variable names
data <- clean_names(data, abbreviations = c("URL"))

# Clean urls
data <- data |>
    mutate(url = str_replace_all(url, "/$", ""))

# Convert to long
data <- data |>
    pivot_longer(
        foregrounds_recovery:headline_qualifies_recovery,
        names_to = "code",
        values_to = "code_present"
    ) |>
    mutate(code_present = code_present == "Y")

# Export
write_parquet(data, "data/data_media.parquet")
write_csv(data, "data/data_media.csv")
