library(readr)
library(dplyr)

nonchart_df <- read_csv("raw_data/150k_sample.csv")
nonchart_df <- nonchart_df %>% select(-c(1:2))
colnames(nonchart_df)[5] <- "year"

save(nonchart_df,file="nonchart_df.RData")
