# Collect project data
library(academictwitteR)

# Use the following line to set bearer in .Renviron file
# set_bearer()

# Check if the bearer token has been activated correctly.
get_bearer()

# Media release and report published on 04 August 2022
# Use Australian Eastern Standard Time (no daylight savings at the time)
query_time_start <- "2022-08-03T14:00:00Z"
query_time_end <- "2022-08-31T14:00:00Z"

# Get tweets and store in JSON
tweets <- get_all_tweets(
    query = "#greatbarrierreef OR great barrier reef",
    start_tweets = query_time_start,
    end_tweets = query_time_end,
    bearer = get_bearer(),
    data_path = "study/twitter/data/",
    n = 100000,
    # Query options
    bind_tweets = FALSE,
    lang = "en")