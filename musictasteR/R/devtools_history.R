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

averagesongs <- read_csv("data-raw/150k_sample.csv")
averagesongs <- nonchart_df %>% select(-c(1:2))
colnames(averagesongs)[5] <- "year"
usethis::use_data(averagesongs)
