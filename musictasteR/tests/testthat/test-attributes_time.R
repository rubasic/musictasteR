'context("tests that the attributes_time function is correctly plotting")

test_that("All input attributes corresponds to the different variables plotted",{
  plot <- attributes_time(billboard_music_dataframe, "Billboard", 1, averagesongs,
                          "Non Billboard", 4, c("danceability","energy", "speechiness","acousticness"), FALSE,
                          c(1960,2010), c("Billboard","Non Billboard"))
  expect_identical(plot$plot_env$attributes, levels(as.factor(plot$data$variable)))
})

test_that("Only years from timerange input are being plotted",{
  plot <- attributes_time(billboard_music_dataframe, "Billboard", 1, averagesongs,
                          "Non Billboard", 4, c("danceability","energy", "speechiness","acousticness"), FALSE,
                          c(1960,2010), c("Billboard","Non Billboard"))
  expect_identical(plot$scales$scales[[2]]$limits,c(1960,2010))
})

test_that("Only chart type (billboard/non billboard) specified by user is plotted",{
  plot <- attributes_time(billboard_music_dataframe, "Billboard", 1, averagesongs,
                          "Non Billboard", 4, c("danceability","energy"), FALSE,
                          c(1960,2010), c("Billboard"))
  expect_identical(plot$plot_env$title_vector, levels(as.factor(plot$data$type)))
})
'
