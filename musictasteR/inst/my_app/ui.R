all_attributes <- c("Danceability" = "danceability" ,"Energy" = "energy",  "Speechiness"  = "speechiness","Acousticness" = "acousticness", "Instrumentalness" = "instrumentalness" ,"Liveness" = "liveness","Valence" = "valence")


library(shiny)


shinyUI(fluidPage(
  titlePanel("musictasteR"),
  sidebarLayout(
    sidebarPanel(
      # SEARCH SPOTIFY START
      textInput("track", "Search for a track and/or an artist"),
      htmlOutput("albumImage"),
      checkboxGroupInput("selectTracks", label = "Select tracks", choices = NULL),
      actionButton("addTracks", label = "Add tracks"),
      actionButton("clearTracks", label = "Clear tracks"),
      # SEARCH SPOTIFY END

      sliderInput(
        "year",
        "Select a year:",
        min = 1960,
        max = 2015,
        value = 2015,
        animate = TRUE,
        round = TRUE,
        ticks = FALSE,
        sep = ""
      ),

      selectInput(
        "x",
        label="X Axis",
        selected = "energy",
        choices = all_attributes
      ),

      selectInput(
        "y",
        label="Y Axis",
        selected  = "danceability",
        choices = all_attributes
      )

    ),

    mainPanel(

      plotly::plotlyOutput("plot")
      #verbatimTextOutput("event")


    )
  )

))
