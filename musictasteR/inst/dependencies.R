# No Remotes ----
# Attachments ----
to_install <- c("billboard", "data.table", "dplyr", "ggplot2", "glue", "gridExtra", "httr", "magrittr", "plotly", "purrr", "readr", "reshape", "shiny", "shinycssloaders", "shinythemes", "shinyWidgets", "spotifyr", "stats", "stringr")
  for (i in to_install) {
    message(paste("looking for ", i))
    if (!requireNamespace(i)) {
      message(paste("     installing", i))
      install.packages(i)
    }

  }
