

library(plotly)
library(shiny)
library(ggplot2)
library(billboard)

hover.plot.shiny <- function(data,x,y,chosen_year)
{
  tracklist <- data %>%
    filter(year == chosen_year | year == "0" ) %>% select(artist_name,year,track_name,x,y)

  plot <- ggplot(tracklist,x=x,y =y) +
    geom_point(aes_string(x=x,y = y,Trackname = as.factor(tracklist$track_name),Artist = as.factor(tracklist$artist_name)),alpha = 0.5) +
    ggtitle(glue::glue("Billboard Top 100 musical charts of {chosen_year}")) +
    theme_minimal() + xlim(0,1) + ylim (0,1)

  hover.plot <- ggplotly(plot) %>% config(displayModeBar = F) %>% layout(xaxis=list(fixedrange=TRUE)) %>% layout(yaxis=list(fixedrange=TRUE)) %>%  layout(hoverlabel = list(bgcolor = "white",
                                                                                                                                                                            font = list(family = "sans serif",
                                                                                                                                                                                        size = 12,
                                                                                                                                                                                        color = "black")));
  return(hover.plot)
}


shinyServer(function(input, output,session) {

  output$plot <- renderPlotly({
    p <- hover.plot.shiny(spotify_track_data, input$x,input$y,input$year)
  })

  output$event <- renderPrint({
    d <- event_data("plotly_hover")
    if (is.null(d)) {
      "Hover to get information about songs"
    }
    else {
      d
    }
  })

})

