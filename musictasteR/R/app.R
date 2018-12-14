#' Launch Shiny
#'
#' @return a shiny app
#' @export
#' @import shinycssloaders
#' @import shinyWidgets
#' @import shinycssloaders
#' @import shinythemes
#' @import shiny
#' @examples
#' \dontrun{
#' launch.shiny()
#' }
launch.shiny <- function()
  {  appDir <- system.file("my_app", package = "musictasteR")  ;shiny::runApp(appDir, display.mode = "normal")}
