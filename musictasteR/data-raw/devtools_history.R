usethis::use_build_ignore("devtools_history.R")
usethis::use_build_ignore("trying_out_functions.Rmd")
usethis::use_build_ignore("temp.R")
#usethis::use_build_ignore("averagesongs-data")
#usethis::use_build_ignore("data/averagesongs")
options(usethis.full_name = "Clara Dionet")
usethis::use_mit_license()
'usethis::use_package("magrittr")
usethis::use_package("dplyr")
usethis::use_package("reshape")
usethis::use_package("ggplot2")
usethis::use_package("stats")
usethis::use_package("billboard")'
usethis::use_build_ignore("plot_time_avg.R")
#devtools::load_all(".")
usethis::use_pipe

#get raw data, clean it and save it in data folder
averagesongs <- read_csv("data-raw/150k_sample.csv")
#remove X1, X columns and empty album_year column
averagesongs <- averagesongs %>% select(-c(1:2,6))
colnames(averagesongs)[4] <- "year"
#remove NA rows
averagesongs <- averagesongs[complete.cases(averagesongs), ]
usethis::use_data(averagesongs, overwrite = TRUE)

#getting snippet from spotify API for testing
spotify_test_pull <- get_tracks_artists("Golddigger")
usethis::use_data(spotify_test_pull, overwrite = TRUE)

#models for K clustering and linear models for principal components
k_model <- readRDS(file = "data-raw/bb_k_clusters_model.rda")
dim_pc_1 <- readRDS(file = "data-raw/bb_princomp_lm_1.rda")
dim_pc_2 <- readRDS(file = "data-raw/bb_princomp_lm_2.rda")

#adding the models for predictions
usethis::use_data(k_model, overwrite = TRUE)
usethis::use_data(dim_pc_1, overwrite = TRUE)
usethis::use_data(dim_pc_2, overwrite = TRUE)

#models for K clustering and linear models for principal components
bb_data <- readr::read_csv("data-raw/billboard_samples_clustered.csv")

#adding the models for predictions
usethis::use_data(bb_data, overwrite = TRUE)
