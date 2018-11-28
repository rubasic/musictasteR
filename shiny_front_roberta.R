
library(shiny)


# Define UI for application that draws a histogram
ui <- fluidPage(
  includeCSS("www/styles.css"),
  
  titlePanel("Analyze your song"),
  
  sidebarLayout(
    sidebarPanel(
      #selectInput("color",label="Color the graph", selected="pink",choices=c("pink","red","yellow","grey") ),
      '   sliderInput("range", "Range:",
      min = 1900, max = 2017,
      value = c(1900,2017))'
  ),
  
  mainPanel(
    
    plotlyOutput("plot"),
    verbatimTextOutput("event")
    
  )
  )
  )

server <- function(input, output,session) {
  
  library(glue)
  library(tidyverse)
  library(tidyverse)
  library(plotly)
  library(billboard)
  library(prenoms)
  
  '  plot_cross <- function(database,year="1960",x_axis=energy,y_axis=danceability){
  year <- enquo(year)
  x_axis <- enquo(x_axis)
  y_axis <- enquo(y_axis)
  x_axis_name <- as.character(x_axis)
  y_axis_name <- as.character(y_axis)
  tracklist <- database %>% filter(year == {!!year} | year == "0" ) %>% select(year,artist_name,track_name,!!x_axis,!!y_axis)
  
  #if we have a "new" element, we show this in a different color, otherwise we will simply display all points in grey
  
  plot <- ggplot(tracklist, aes(!!x_axis, !!y_axis))  +
  geom_point(aes(text = track_name, artist= artist_name, size = 0.1),alpha = 1/2) + theme_minimal() + 
  xlim(0,1) + ylim (0,1)
  
  #  ggplotly(plot, tooltip = c("text", "artist",glue::glue("{x_axis_name}"),glue::glue("{y_axis_name}") ))
  
}'
  
  tracklist <- spotify_track_data %>% filter(year == "2015" | year == "0" ) %>% select(year,artist_name,track_name,danceability, energy)
  
  plot_test <- ggplot(tracklist, aes(danceability, energy))  +
    geom_point(aes(text = track_name, artist= artist_name, size = 0.1),alpha = 1/2) + theme_minimal() + 
    xlim(0,1) + ylim (0,1)
  
  plotly_test <-  ggplotly(plot_test, tooltip = c("text", "artist","danceability", "energy"))


  output$data  <- reactive({renderDataTable(prenoms %>% filter(name == input$name) )
  })
  
  test <- unique(prenoms$name)
  
  observe({
    updateSelectInput(session=session, 
                      selected = "Vincent",
                      inputId="dropdown_name",
                      choices=test)
  })
  
  
  output$plot <- renderPlotly({
    plotly_test 
  })
  
  output$event <- renderPrint({
    d <- event_data("plotly_hover")
    if (is.null(d)) "Hover on a point!" else d
  })
  
  }

# Run the application 
shinyApp(ui = ui, server = server)

