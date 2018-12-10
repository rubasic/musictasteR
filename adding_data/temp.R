library(readr)
library(dplyr)

nonchart_df <- read_csv("raw_data/150k_sample.csv")
nonchart_df <- nonchart_df %>% select(-c(1:2))
colnames(nonchart_df)[5] <- "year"

nonchart_df <- nonchart_df %>% select(-c(1:6,19:26))
colnames(nonchart_df) <- c("year", "danceability","energy","key","loudness","mode","speechiness","acousticness","instrumentalness","liveness","valence","tempo" )
nonchart_df <- nonchart_df[complete.cases(nonchart_df), ]

averagesongs <- read_csv("data-raw/150k_sample.csv")
averagesongs <- averagesongs %>% select(-c(1:2))
colnames(averagesongs)[5] <- "year"
averagesongs <- averagesongs[complete.cases(averagesongs), ]


save(nonchart_df,file="nonchart_df.RData")

dim(averagesongs)
levels(as.factor(averagesongs$year))

dim(averagesongs)
colnames(averagesongs)
