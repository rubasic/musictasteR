all_attributes <- c("danceability" ,"energy" ,"mode", "speechiness","acousticness", "instrumentalness" ,"liveness","valence" ,"tempo")

# Define UI for application that draws a histogram
ui <- fluidPage(

   titlePanel("Song Attributes over Time"),

   sidebarLayout(
      sidebarPanel(
        checkboxGroupInput(
          "attributes",
          label = "Choose attributes:",
          selected = "danceability",
          choices = all_attributes
        ),
        sliderInput(
          "timerange",
          label="Choose a time range",
          min = 1960,
          max = 2015,
          value = c(1960,2015),
          step = 1,
          sep = "",
          animate = TRUE
        ),
      checkboxInput(
        "boxplot",
        label = "Boxplot",
        value = FALSE
      ),
      checkboxGroupInput(
        "billboard",
        label = "Choose music popularity:",
        selected = c("Billboard", "Non Billboard"),
        choices = c("Billboard", "Non Billboard")
      )
              ),
      mainPanel(
         plotOutput("attributes_time")
      )
   )
)

server <- function(input, output) {
  library(shiny)
  library(tidyverse)
  library(spotifyr)
  library(dplyr)
  library(tidyverse)
  library(httr)
  library(stringr)
  library(billboard)
  library(musictasteR)
  library(reshape)

  data(averagesongs)
  topsongs <- billboard::spotify_track_data

  output$attributes_time <- renderPlot({
    attributes_time(topsongs, "Billboard", 1, averagesongs, "Non Billboard", 4, input$attributes, input$boxplot, input$timerange, input$billboard)
  })

}

# Run the application
shinyApp(ui = ui, server = server)

