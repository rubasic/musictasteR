context("testing formatting function")

test_that("returned dataframe contains track_name", {
  formated_songs <- format_new_songs(spotify_test_pull)
  expect_true("track_name" %in% colnames(formated_songs))
})
#class of the col values
#returns a certain format etc.

test_that("returned dataframe contains artist_name", {
  formated_songs <- format_new_songs(spotify_test_pull)
  expect_true("artist_name" %in% colnames(formated_songs))
})

test_that("returned dataframe is data frame", {
  formated_songs <- format_new_songs(spotify_test_pull)
  expect_true(is.data.frame(formated_songs))
})
