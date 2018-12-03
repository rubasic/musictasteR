library(shiny)
library(glue)
library(tidyverse)
library(plotly)
library(billboard)
library(prenoms)
library(googleCharts)

xlim <- list(
  min = min(spotify_track_data$danceability),
  max = max(spotify_track_data$danceability) 
)
ylim <- list(
  min = min(spotify_track_data$energy),
  max = max(spotify_track_data$energy) 
)


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
      googleChartsInit(),
      
      h2("Song performance over time"),
      
      googleBubbleChart("chart",
                        width="100%", height = "475px",
                        # Set the default options for this chart; they can be
                        # overridden in server.R on a per-update basis. See
                        # https://developers.google.com/chart/interactive/docs/gallery/bubblechart
                        # for option documentation.
                        options = list(
                          fontName = "Source Sans Pro",
                          fontSize = 13,
                          # Set axis labels and ranges
                          hAxis = list(
                            title = "X Axis",
                            viewWindow = xlim
                          ),
                          vAxis = list(
                            title = "Y AXIS",
                            viewWindow = ylim
                          ),
                          # PADDING
                          chartArea = list(
                            top = 50, left = 75,
                            height = "75%", width = "75%"
                          ),
                          # Allow pan/zoom
                          explorer = list(),
                          # Set bubble visual props
                          bubble = list(
                            opacity = 0.4, stroke = "none",
                            # Hide bubble label
                            textStyle = list(
                              color = "none"
                            )
                          ),
                          # Set fonts
                          titleTextStyle = list(
                            fontSize = 16
                          ),
                          tooltip = list(
                            textStyle = list(
                              fontSize = 12
                            )
                          )
                        )
      ),
      
      plotlyOutput("plot"),
      verbatimTextOutput("event")
      
    )
  )
)




server <- function(input, output,session) {
  
  tracklist <- reactive({
  t <- spotify_track_data %>% 
    filter(year == {input$year} | year == "0" ) %>% select(artist_name,danceability,energy,year,track_name)
    print(t)
    
  })
  
  defaultColors <- c("#3366cc", "#dc3912", "#ff9900", "#109618", "#990099", "#0099c6", "#dd4477")
  series <- structure(
    lapply(defaultColors, function(color) { list(color=color) }),
    names = levels(data$Region)
  )
  
  output$chart <- reactive({
    # Return the data and options
    # Return the data and options
    list(
      data = googleDataTable(tracklist()),
      options = list(
      )
    )
  })
  
  
  plot_cross <- function(database,year="1960",x_axis,y_axis)
  {
    year <- enquo(year)
    x_axis <- enquo(x_axis)
    y_axis <- enquo(y_axis)
    
    x_axis_name <- as.character(x_axis)
    y_axis_name <- as.character(y_axis)
    
    #if we have a "new" element, we show this in a different color, otherwise we will simply display all points in grey

    plot <- ggplot(tracklist(), aes(!!x_axis,!!y_axis))  +  geom_point(aes(text = track_name, artist= artist_name, size = 0.01),alpha = 1/2) + theme_minimal() + xlim(0,1) + ylim (0,1)
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

