#' Converts stuff
#'
#' @param temp_F a number
#'
#' @return The temp to kelvin
#' @export
#'
#' @examples
#' fahrenheit_to_kelvin(32)
fahrenheit_to_kelvin <- function(temp_F) {
  temp_K <- ((temp_F - 32) * (5/9)) + 273.15
  temp_K
}
