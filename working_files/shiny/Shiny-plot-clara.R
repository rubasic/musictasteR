all_attributes <- c("explicit", "danceability" ,"energy" ,"mode", "speechiness","acousticness", "instrumentalness" ,"liveness","valence" ,"tempo")

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   titlePanel("Song Attributes over Time"),
   
   sidebarLayout(
      sidebarPanel(
        checkboxGroupInput( 
          "attributes", 
          label = "Choose attributes:",
          selected = "explicit",
          choices = all_attributes
        ),
        sliderInput( 
          "timerange",
          label="Choose a time range",
          min = 1960,
          max = 2015,
          value = c(1960,2015),
          step = 1,
          sep = "",
          animate = TRUE
        ),
      checkboxInput( 
        "boxplot", 
        label = "Boxplot",
        value = FALSE
      )
              ),
      mainPanel(
         plotOutput("plot_avg")
      )
   )
)

server <- function(input, output) {
  library(shiny)
  library(tidyverse)
  library(spotifyr)
  library(dplyr)
  library(tidyverse)
  library(httr)
  library(stringr)
  library(billboard)
  library(reshape)

  plot_avg <- function(vars, boxplot, timerange) {
    if(boxplot == FALSE) {
    # get mean for each attribute
    df_avg <- aggregate(df[,vars], list(df$year), mean)
    colnames(df_avg)[1] <- "year"
    # reshape function for plot
    df_melt <- melt(as.data.frame(df_avg), id = "year")
    # year should be continuous
    df_melt$year <- as.numeric(as.character(df_melt$year))
    ggplot(df_melt, aes(x=year, y=value, color=variable)) + ylim(0,1)  + geom_line(size=1) + xlim(input$timerange)
    }
    else {
      df_time <- as.data.frame(df) %>% filter(year %in% timerange[1]:timerange[2])
      df_box_melt <- melt(df_time,id.vars="year", measure.vars=vars)
      ggplot(df_box_melt) + geom_boxplot(aes(x=year, y=value, fill=variable)) + theme(axis.text.x = element_text(angle=90)) + ylim(0,1)  
    }
  }
  
  output$plot_avg <- renderPlot({
    plot_avg(input$attributes, input$boxplot, input$timerange)
  })

}

# Run the application 
shinyApp(ui = ui, server = server)

