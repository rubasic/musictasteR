library(shiny)

library(glue)
library(tidyverse)
library(tidyverse)
library(plotly)
library(billboard)
library(prenoms)


all_attributes <- c("danceability" ,"energy", "speechiness","acousticness", "instrumentalness" ,"liveness","valence")

ui <- fluidPage(
  includeCSS("www/styles.css"),
  
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
        ticks = FALSE
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




server <- function(input, output,session) {
  
  
 plot_cross <- function(database,year="1960",x_axis,y_axis)
   {
    year <- enquo(year)
    x_axis <- enquo(x_axis)
    y_axis <- enquo(y_axis)

    x_axis_name <- as.character(x_axis)
    y_axis_name <- as.character(y_axis)
    tracklist <- database %>% filter(year == {!!year} | year == "0" ) %>% select(year,artist_name,track_name,!!x_axis,!!y_axis)
   print(tracklist)
    
    #if we have a "new" element, we show this in a different color, otherwise we will simply display all points in grey
    
    plot <- ggplot(tracklist, aes(!!x_axis,!!y_axis))  +  geom_point(aes(text = track_name, artist= artist_name, size = 0.01),alpha = 1/2) + theme_minimal() + xlim(0,1) + ylim (0,1)
    
  
    
  #  ggplotly(plot, tooltip = c("text", "artist",glue::glue("{~x_axis_name}"),glue::glue("{~y_axis_name}") ))
   
}
  
  output$plot <- renderPlotly({
    plot_cross(spotify_track_data,year=input$year,danceability,energy)
  })
  
  output$event <- renderPrint({
    d <- event_data("plotly_hover")
    if (is.null(d)) "Hover on a point!" else d
  })
  
  }

# Run the application 
shinyApp(ui = ui, server = server)

