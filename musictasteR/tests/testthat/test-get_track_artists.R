context("testing get_track_artists to pull songs from spotify API")

test_that("request returns a dataframe with 20 rows", {
  spotify_pull <- get_tracks_artists("hey")
  expect_equal(nrow(spotify_pull),20)
})

test_that("returned object includes artist_name", {
  spotify_pull <- get_tracks_artists("hey")
  expect_true("artist_name" %in% colnames(spotify_pull))
})


test_that("returned object includes artist_name", {
  spotify_pull <- get_tracks_artists("hey")
  expect_true("artist_name" %in% colnames(spotify_pull))
})


test_that("returned object includes album_name", {
  spotify_pull <- get_tracks_artists("hey")
  expect_true("album_name" %in% colnames(spotify_pull))
})

test_that("returned object includes release_date", {
  spotify_pull <- get_tracks_artists("hey")
  expect_true("release_date" %in% colnames(spotify_pull))
})

test_that("returned object includes track_artist", {
  spotify_pull <- get_tracks_artists("hey")
  expect_true("track_artist" %in% colnames(spotify_pull))
})


