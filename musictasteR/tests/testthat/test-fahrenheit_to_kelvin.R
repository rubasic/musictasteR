context("test dummy function")

test_that("our fahrenheit function works", {
  a <- fahrenheit_to_kelvin(45)
  expect_equal(a,(45 - 32) * (5/9) + 273.15)
})
