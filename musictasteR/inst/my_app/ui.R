all_attributes <- c("Danceability" = "danceability" ,"Energy" = "energy",  "Speechiness"  = "speechiness","Acousticness" = "acousticness" ,"Liveness" = "liveness","Valence" = "valence")

library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinycssloaders)
library(dplyr)


fluidPage(theme = shinytheme("slate"),
          includeCSS("www/styles.css"),
          shinyWidgets::chooseSliderSkin("Shiny", color = "#00c193"),


  headerPanel("",
            tags$head(
              tags$img(src="https://raw.githubusercontent.com/rubasic/rubasic/master/musictasteR/inst/my_app/www/headrrrr.png",
                       height = 60, style = "display: block; margin-left: 40px;
                       margin-top:25px; margin-bottom: -15px;")
            )),


  ## SIDEBAR
  sidebarPanel(width = 3,

      # SEARCH SPOTIFY START
      textInput("track", label = NULL, placeholder = "Search for a track and/or an artist"),
      htmlOutput("albumImage"),
      shinyWidgets::awesomeCheckboxGroup("selectTracks", label = NULL, choices = NULL, inline = TRUE),
      actionButton("addTracks", label = strong("Add tracks")),
      actionButton("clearTracks", label = strong("Clear tracks")),
      br(),
      br(),
      tags$b("Your tracks"),
      tableOutput("yourTracks")
      # SEARCH SPOTIFY END

    ),

  ## BODY
  mainPanel(
  tabsetPanel(

      tabPanel(strong("Plot Roberta"),
               plotly::plotlyOutput("plot"),
               br(),
               p("This plot shows ..."),

               sliderInput("year", label = NULL, min = 1960, max = 2015,
                 value = 2015, animate = TRUE, round = TRUE, ticks = FALSE, sep = "",width = 1000
               ),
               shinyWidgets::radioGroupButtons(
                 "x", label = NULL, selected = "energy", choices = all_attributes
               ),

               shinyWidgets::radioGroupButtons(
                 "y", label= NULL, selected  = "danceability", choices = all_attributes
               )),

      tabPanel(strong("Plot Clara"),
               plotOutput("attributes_time") %>% withSpinner(color = "#999b9e"),

               br(),
               p("This plot shows ..."),

               fluidRow(
                 column(3,
                        h4("Choose attribute(s)"),
                        shinyWidgets::awesomeCheckboxGroup(
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
                          inputId = "boxplot", label = NULL, value = FALSE
                        )
                 )


               ) # FLUIDROW END
      ),

      tabPanel(strong("Plot Mirae"),
               plotOutput("plot_logit"),
               br(),
               p("This plot shows ..."),
               actionButton("updateLogit", label = "Create plot"),
               shinyWidgets::awesomeCheckboxGroup("selectLogit", choices = NULL, label = NULL, inline = TRUE),
               DT::dataTableOutput("logit_df")
               ),

      tabPanel(strong("Yearwise Song Clusters"),
               plotly::plotlyOutput("plot_cluster"),
               br(),
               p("See which song your input music is the most similar to in which year! Select a song/list of songs, select a year and hover over the result to see song details! Songs that are clustered together indicate a weak similarity between them in terms of musical features, and songs that are closeby in the plot are strongly similar."),
               strong("Select a year"),
               sliderInput("year_cluster", label = NULL, min = 1960, max = 2015,
                           value = 2015, animate = TRUE, round = TRUE, ticks = FALSE, sep = ""
               )
      ),

      tabPanel(strong("Added songs"),
               DT::dataTableOutput("masterDF")
      ),

      tabPanel(strong("About the app"))

    #verbatimTextOutput("event")
  )
))
