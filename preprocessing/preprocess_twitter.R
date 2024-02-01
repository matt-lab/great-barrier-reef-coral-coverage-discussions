    # Libraries
    library(tidyverse)
    library(academictwitteR)
    library(arrow)

    # Data path
    data_path <- "study/twitter/data"

    # Collect tweets from JSON
    data <- bind_tweets(
        data_path = data_path,
        output_format = "tidy")


    data <- data |>
        select(
            -starts_with("sourcetweet"),
            -user_profile_image_url,
            -user_verified,
            -user_pinned_tweet_id,
            -user_tweet_count,
            -user_list_count,
            -conversation_id,
            -possibly_sensitive)

    # Data on urls and media is missing
    # Extract this and bind to data
    data_raw <- bind_tweets(data_path = data_path, output_format = "raw")

    data_urls <- as_tibble(data_raw$tweet.entities.urls)

    # Code url characteristics
    data_urls <- data_urls |>
        mutate(url_type = "urls_external") |>
        mutate(url_type = ifelse(!is.na(media_key), "urls_media", url_type)) |>
        mutate(url_type = ifelse(
            str_detect(display_url, "^twitter.com"),
            ifelse(
                str_detect(expanded_url, "/status/"),
                "urls_internal_status",
                "urls_internal_other"),
            url_type))
    # Convert to wide format and bind with data
    data_urls <- data_urls |>
        mutate(url = ifelse(is.na(unwound_url), expanded_url, unwound_url)) |>
        select(tweet_id, url, url_type) |>
        group_by(tweet_id, url_type) |>
        summarise(url = str_c(url, collapse =  ",")) |>
        pivot_wider(
            names_from = "url_type",
            values_from = "url"
        ) |>
        ungroup()
    data <- data |>
        left_join(data_urls, by = "tweet_id")

# Remove retweets
data_retweets <- data_raw$tweet.referenced_tweets |>
    as_tibble() |>
    rename(tweet_id_typed = id)
data <- data |>
    left_join(data_retweets, by = 'tweet_id')

# Recode time data
data <- data |>
    mutate(across(ends_with("created_at"),
    as.POSIXct, tz = "GMT", format = "%Y-%m-%dT%H:%M:%OSZ"))

# Export as parquet
write_parquet(data, "data/data_twitter.parquet")
write_csv(select(data, tweet_id), "data/data_twitter_ids.csv")

# TODO add data dictionary