library(shiny)
library(glue)
library(tidyverse)
library(plotly)
library(billboard)
library(prenoms)
library(shinyWidgets)

all_attributes <- c("Danceability" = "danceability" ,"Energy" = "energy",  "Speechiness"  = "speechiness","Acousticness" = "acousticness", "Instrumentalness" = "instrumentalness" ,"Liveness" = "liveness","Valence" = "valence")

ui <- fluidPage(
  includeCSS("www/styles.css"),
 # setBackgroundImage(src = "www/music_photo.jpg"),


  titlePanel("Analyze your song"),


  sidebarLayout(
    sidebarPanel(

      ## add as next step fake typing in and match with list
      #once song is selected, it shows as selected song (little card) and can be deleted again
      selectInput(
        "newsong",
        label = "Add your own song",
        selected = "Oops I did it again",
        choices = c("Oops I did it again", "red", "yellow", "grey")
      ),

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

    plotlyOutput("plot"),
    verbatimTextOutput("event")

  )
  )
  )


<- <- <-

server <- function(input, output,session) {

  tracklist <- reactive({
    t <- spotify_track_data %>%
      filter(year == {input$year} | year == "0" ) %>% select(artist_name,year,track_name,input$x,input$y)
    })

  x_axis <- reactive({
    x_axis <- input$x
  })

  y_axis <- reactive({
    y_axis <- input$y
  })

 plot_cross <- function(tracklist)
   {
   print(tracklist)

    #if we have a "new" element, we show this in a different color, otherwise we will simply display all points in grey

    plot <- ggplot(tracklist,x=x_axis(),y = y_axis()) +
                     geom_point(aes_string(x=x_axis(),y = y_axis(),Trackname = as.factor(tracklist$track_name),Artist = as.factor(tracklist$artist_name)),alpha = 0.5) +
      ggtitle(glue::glue("Billboard Top 100 musical charts of {input$year}")) +
                     theme_minimal() + xlim(0,1) + ylim (0,1)

      ggplotly(plot) %>% config(displayModeBar = F) %>% layout(xaxis=list(fixedrange=TRUE)) %>% layout(yaxis=list(fixedrange=TRUE)) %>%  layout(hoverlabel = list(bgcolor = "white",
                                                                                                                                                                  font = list(family = "sans serif",
                                                                                                                                                                              size = 12,
                                                                                                                                                                              color = "black")))

}

  output$plot <- renderPlotly({
    plot_cross(tracklist())
  })

  text <- function(d){

    track_name <- tracklist[d,3]
    artist_name <- tracklist[d,1]
    print(track_name)
    return("test")
  }

  output$event <- renderPrint({
    d <- event_data("plotly_hover")
    if (is.null(d)) {
    "Hover to get information about songs"
    }
    else {
      d
    }
  })

  }

# Run the application
shinyApp(ui = ui, server = server)

