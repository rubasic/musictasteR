all_attributes <- c("Danceability" = "danceability" ,"Energy" = "energy",  "Speechiness"  = "speechiness","Acousticness" = "acousticness", "Instrumentalness" = "instrumentalness" ,"Liveness" = "liveness","Valence" = "valence")


library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinycssloaders)
library(dplyr)


fluidPage(theme = shinytheme("slate"),
          includeCSS("www/styles.css"),

  headerPanel("",
            tags$head(
              tags$img(src="https://raw.githubusercontent.com/rubasic/rubasic/master/musictasteR/inst/my_app/www/headrrrr.png",
                       height = 60, style = "display: block; margin-left: 40px;
                       margin-top:25px; margin-bottom: -10px;")
            )),


  ## SIDEBAR
  sidebarPanel(width = 3,

      # SEARCH SPOTIFY START
      textInput("track", label = NULL, placeholder = "Search for a track and/or an artist"),
      htmlOutput("albumImage"),
      shinyWidgets::awesomeCheckboxGroup("selectTracks", label = NULL, choices = NULL, inline = TRUE),
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
               plotly::plotlyOutput("plot"),
               br(),
               p("This plot shows ..."),

               h4("Select a year"),
               sliderInput("year", label = NULL, min = 1960, max = 2015,
                 value = 2015, animate = TRUE, round = TRUE, ticks = FALSE, sep = "",width = 1000
               ),

               h4("X Axis"),
               shinyWidgets::radioGroupButtons(
                 "x", label = NULL, selected = "energy", choices = all_attributes
               ),

               h4("Y Axis"),
               shinyWidgets::radioGroupButtons(
                 "y", label= NULL, selected  = "danceability", choices = all_attributes
               )),

      tabPanel("Plot Clara",
               plotOutput("attributes_time") %>% withSpinner(color = "#999b9e"),

               br(),
               p("This plot shows ..."),

               fluidRow(
                 column(3,
                        h4("Choose attribute(s)"),
                        checkboxGroupInput(
                          "attributes", label = NULL,
                          selected = c("danceability", "energy", "speechiness",
                                       "acousticness", "instrumentalness", "liveness", "valence"),
                          choices = all_attributes
                        )
                 ),

                 column(3,
                        h4("Choose a time range"),
                        sliderInput(
                          "timerange", label= NULL, min = 1960, max = 2015,
                          value = c(1960,2015), step = 1, sep = "", animate = TRUE
                        )
                 ),

                 column(3,
                        h4("Choose music popularity"),
                        shinyWidgets::checkboxGroupButtons(
                          "billboard", label = NULL,
                          selected = c("Billboard", "Non Billboard"),
                          choices = c("Billboard", "Non Billboard")
                        )
                 ),

                 column(3,
                        h4("Boxplot"),
                        shinyWidgets::materialSwitch(
                          "boxplot", label = NULL, value = FALSE
                        )
                 )


               ) # FLUIDROW END
      ),

      tabPanel("Plot Mirry"),

      tabPanel("Plot Akshay"),

      tabPanel("Added songs",
               DT::dataTableOutput("masterDF")
    )

    #verbatimTextOutput("event")
  )
))
