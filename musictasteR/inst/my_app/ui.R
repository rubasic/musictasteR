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
      actionButton("clearTracks", label = "Clear tracks")
      # SEARCH SPOTIFY END

    ),

    mainPanel(
      tabsetPanel(

        tabPanel("Plot Roberta",
                 plotly::plotlyOutput("plot"),
                 sliderInput("year", "Select a year:", min = 1960, max = 2015,
                   value = 2015, animate = TRUE, round = TRUE, ticks = FALSE, sep = ""
                 ),

                 selectInput(
                   "x", label="X Axis", selected = "energy", choices = all_attributes
                 ),

                 selectInput(
                   "y", label="Y Axis", selected  = "danceability", choices = all_attributes
                 )),

        tabPanel("Plot Clara",
                 plotOutput("attributes_time"),

                 checkboxGroupInput(
                   "attributes", label = "Choose attributes:",
                   selected = "danceability",choices = all_attributes
                 ),

                 sliderInput(
                   "timerange", label="Choose a time range", min = 1960, max = 2015,
                   value = c(1960,2015), step = 1, sep = "", animate = TRUE
                 ),

                 checkboxInput(
                   "boxplot", label = "Boxplot", value = FALSE
                 ),

                 checkboxGroupInput(
                   "billboard", label = "Choose music popularity:",
                   selected = c("Billboard", "Non Billboard"),
                   choices = c("Billboard", "Non Billboard")
                 )),

        tabPanel("Plot Mirry"),

        tabPanel("Plot Akshay"),

        tabPanel("Added songs",
                 tableOutput("masterDF"))
      )

      #verbatimTextOutput("event")


    )
  )

))
