all_attributes <- c("Danceability" = "danceability" ,"Energy" = "energy",  "Speechiness"  = "speechiness","Acousticness" = "acousticness", "Instrumentalness" = "instrumentalness" ,"Liveness" = "liveness","Valence" = "valence")


library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinycssloaders)
library(dplyr)


fluidPage(theme = shinytheme("slate"),

  headerPanel("",
            tags$head(
              tags$img(src="inst/my_app/headr.png", height="200px")
            )),


  ## SIDEBAR
  sidebarPanel(

      # SEARCH SPOTIFY START
      textInput("track", label = NULL, placeholder = "Search for a track and/or an artist"),
      htmlOutput("albumImage"),
      br(),
      shinyWidgets::awesomeCheckboxGroup("selectTracks", label = "Select tracks", choices = NULL),
      actionButton("addTracks", label = "Add tracks"),
      actionButton("clearTracks", label = "Clear tracks"),
      br(),
      br(),
      tags$b("Your tracks"),
      tableOutput("yourTracks")
      # SEARCH SPOTIFY END

    ),

  ## BODY
  mainPanel(
  tabsetPanel(

      tabPanel("Plot Roberta",
               plotly::plotlyOutput("plot") %>% withSpinner(color = "#999b9e"),
               sliderInput("year", "Select a year:", min = 1960, max = 2015,
                 value = 2015, animate = TRUE, round = TRUE, ticks = FALSE, sep = "",width = 1000
               ),

               shinyWidgets::radioGroupButtons(
                 "x", label="X Axis", selected = "energy", choices = all_attributes
               ),

               shinyWidgets::radioGroupButtons(
                 "y", label="Y Axis", selected  = "danceability", choices = all_attributes
               )),

      tabPanel("Plot Clara",
               plotOutput("attributes_time") %>% withSpinner(color = "#999b9e"),

               br(),

               fluidRow(
                 column(3,
                        checkboxGroupInput(
                          "attributes", label = "Choose attributes:",
                          selected = c("danceability", "energy", "speechiness",
                                       "acousticness", "instrumentalness", "liveness", "valence"),
                          choices = all_attributes
                        )
                 ),

                 column(3,
                        sliderInput(
                          "timerange", label="Choose a time range", min = 1960, max = 2015,
                          value = c(1960,2015), step = 1, sep = "", animate = TRUE
                        )
                 ),

                 column(3,
                        shinyWidgets::materialSwitch(
                          "boxplot", label = "Boxplot", value = FALSE
                        )
                 ),

                 column(3,
                        shinyWidgets::checkboxGroupButtons(
                          "billboard", label = "Choose music popularity:",
                          selected = c("Billboard", "Non Billboard"),
                          choices = c("Billboard", "Non Billboard")
                        )
                 )
               ) # FLUIDROW END
      ),

      tabPanel("Plot Mirry"),

      tabPanel("Plot Akshay"),

      tabPanel("Added songs",
               tableOutput("masterDF"))
    )

    #verbatimTextOutput("event")
  )
)
