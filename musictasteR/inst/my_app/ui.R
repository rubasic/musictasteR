
all_attributes <- c("Danceability" = "danceability" ,"Energy" = "energy",  "Speechiness"  = "speechiness","Acousticness" = "acousticness" ,"Liveness" = "liveness","Valence" = "valence")

library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinycssloaders)
library(dplyr)

fluidPage(theme = shinytheme("slate"),
          includeCSS("www/styles.css"),
          shinyWidgets::chooseSliderSkin("Shiny", color = "#00c193"),

  ## HEADER
  headerPanel("", tags$head(tags$img(
      src="https://raw.githubusercontent.com/rubasic/rubasic/master/musictasteR/inst/my_app/www/headrrrr.png",
      height = 60, style = "display: block; margin-left: 40px;
      margin-top:25px; margin-bottom: -15px;"))
      ),


  ## SIDEBAR
  sidebarPanel(width = 3,
      textInput("track", label = NULL, placeholder = "Search for a track and/or an artist"),
      htmlOutput("albumImage"),
      shinyWidgets::awesomeCheckboxGroup("selectTracks", label = NULL, choices = NULL, inline = TRUE),
      actionButton("addTracks", label = strong("Add tracks")),
      actionButton("clearTracks", label = strong("Clear tracks")),
      br(),
      br(),
      strong("Your songs"),
      tableOutput("yourTracks")
    ),

  ## MAIN PANEL
  mainPanel(
    tabsetPanel(

      tabPanel(strong("Plot Roberta"),
               plotly::plotlyOutput("plot"),
               br(),
               p("Visualize the top 100 songs in terms of 2 music characteristics for each year! Add your own songs for comparison by using the search bar on the left - they will show up in pink."),
               sliderInput("year", label = NULL, min = 1960, max = 2015,
                 value = 2015, animate = TRUE, round = TRUE, ticks = FALSE, sep = "",width = 1000),
               shinyWidgets::radioGroupButtons(
                 "x", label = NULL, selected = "energy", choices = all_attributes),
               shinyWidgets::radioGroupButtons(
                 "y", label= NULL, selected  = "danceability", choices = all_attributes)
              ),

      tabPanel(strong("Plot Clara"),
               plotOutput("attributes_time") %>% withSpinner(color = "#999b9e"),
               br(),
               p("Plot the music characteristics of billboard songs and/or average songs over time! Select the attributes, timerange, and type of plot you want to see! Up to 2 features recommended for the boxplot option."),
               fluidRow(
                 column(3,
                        h4("Choose attribute(s)"),
                        shinyWidgets::awesomeCheckboxGroup(
                          "attributes", label = NULL,
                          selected = "danceability",
                          choices = all_attributes)
                 ),

                 column(3,
                        h4("Choose a time range"),
                        sliderInput(
                          "timerange", label= NULL, min = 1960, max = 2015,
                          value = c(1960,2015), step = 1, sep = "", animate = TRUE)
                 ),

                 column(3,
                        h4("Choose music popularity"),
                        shinyWidgets::checkboxGroupButtons(
                          "billboard", label = NULL,
                          selected = c("Billboard", "Non Billboard"),
                          choices = c("Billboard", "Non Billboard"))
                 ),

                 column(3,
                        h4("Boxplot"),
                        shinyWidgets::materialSwitch(
                          inputId = "boxplot", label = NULL, value = FALSE))
               )
      ),
      # End tab 2

      tabPanel(strong("Plot Mirae"),
               plotOutput("plot_logit"),
               br(),
               p("Get the probability of your song(s) reaching the top 100 billboard chart over time! For each song, get the maximum and minimum probabilities."),
               actionButton("updateLogit", label = "Create plot"),
               shinyWidgets::awesomeCheckboxGroup("selectLogit", choices = NULL, label = NULL, inline = TRUE),
               DT::dataTableOutput("logit_df")
               ),

      tabPanel(strong("Yearwise Song Clusters"),
               plotly::plotlyOutput("plot_cluster"),
               br(),
               p("See which song your input music is the most similar to in which year! Select a song/list of songs, select a year and hover over the result to see song details! Songs clustered together indicate a slight similarity in terms of musical features, and songs closeby in the plot are strongly similar."),
               strong("Select a year"),
               sliderInput("year_cluster", label = NULL, min = 1960, max = 2015,
                           value = 2015, animate = TRUE, round = TRUE, ticks = FALSE, sep = "", width = 1000)
               ),

      tabPanel(strong("Your songs"),
               DT::dataTableOutput("masterDF")
               ),

      tabPanel(strong("About the app"),
      p(" "),
      p("This Shiny app allows to visualise, compare and cluster top and average songs according to their music characteristics. Top songs correspond to ones which have been featured in the Top100 Billboard chart over the years 1960 to 2015."),
      p("The sidebar on the left displays all the songs added by the user. The search function takes as input any string and returns a list of the songs most related to this string. The user simply ticks the song(s) he wishes to add to his saved tracks."),
      p("The first tab, [NAME] plots billboard songs according to 2 attributes entered by the user for a given year. The user may also add any input song(s) for comparison and they will be displayed in pink."),
      p("The second tab, [NAME] plots the music characteristics of top and/or average (Billboard vs. Non Billboard) songs over time. The user can specify the attributes, the time range, type of popularity and type of plot to be displayed. The boxplots gives more information about the data as it shows the distribution of each variable per year, whereas the average plots allow a global visualisation of multiple attributes. It is recommended to plot only up to 2-3 features for boxplot as the plot rapidly gets packed."),
      p("The third tab, [NAME] plots the probabilities for the user's saved tracks to be in the top 100. The minimum and maximum probabilities, along with the release year are labeled."),
      p("The fourth tab, [NAME] plots the clusters of the billboard songs according to the first two principal components. The user may also add any input song(s) for comparison. Songs clustered together (of the same color) are slightly similar in terms of musical features, whereas songs closeby in the plot are strongly similar.")
      )
    )
  )
)

