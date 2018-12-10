all_attributes <- c("danceability" ,"energy" ,"mode", "speechiness","acousticness", "instrumentalness" ,"liveness","valence" ,"tempo")

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   titlePanel("Song Attributes over Time"),
   
   sidebarLayout(
      sidebarPanel(
        checkboxGroupInput( 
          "attributes", 
          label = "Choose attributes:",
          selected = "danceability",
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
      ),
      checkboxGroupInput( 
        "billboard", 
        label = "Choose music popularity:",
        selected = c("Billboard", "Non Billboard"),
        choices = c("Billboard", "Non Billboard")
      )
              ),
      mainPanel(
         plotOutput("attributes_time")
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
  chart_df <- billboard::spotify_track_data
  nonchart_df <- read_csv("../150k_sample.csv")
  nonchart_df <- nonchart_df %>% select(-c(1:6,19:26))
  colnames(nonchart_df) <- c("year", "danceability","energy","key","loudness","mode","speechiness","acousticness","instrumentalness","liveness","valence","tempo" )
  nonchart_df <- nonchart_df[complete.cases(nonchart_df), ]
  
   attributes_time <- function(chart_df, nonchart_df, vars, boxplot, timerange, billboard) {
    if(boxplot == FALSE) {
      # get mean for each attribute
      chart_df_avg <- aggregate(chart_df[,vars], list(chart_df$year), mean)
      nonchart_df_avg <- aggregate(nonchart_df[,vars], list(nonchart_df$year), mean)
      # rename first column (Group1 by default)
      colnames(chart_df_avg)[1] <- "year"
      colnames(nonchart_df_avg)[1] <- "year"
      # reshape function for plot:
      # df melt reshapes data frame with 3 columns: year, variable and value (value=avg here)
      df_melt <- melt(as.data.frame(chart_df_avg), id = "year")
      df_melt_non_chart <- melt(as.data.frame(nonchart_df_avg),id="year")
      # add col before binding
      df_melt$chart <- "Billboard"
      df_melt_non_chart$chart <- "Non Billboard"
      df_avg <- rbind(df_melt,df_melt_non_chart)
      # year as numeric for continuous plot
      df_avg$year <- as.numeric(as.character(df_avg$year))
      ggplot(df_avg %>% filter(chart %in% billboard), aes(x=year, y=value, color=variable, linetype = chart)) + ylim(0,1)  + geom_line(size=1) + xlim(input$timerange)
      
    }
    else {
      # filter over wanted time
      df_time <- as.data.frame(chart_df) %>% filter(year %in% timerange[1]:timerange[2])
      df_time2 <- as.data.frame(nonchart_df) %>% filter(year %in% timerange[1]:timerange[2])
      # reshape 
      df_box_melt <- melt(df_time,id.vars="year", measure.vars=vars)
      df_box_melt_non_chart <-  melt(df_time2,id.vars="year", measure.vars=vars)
      # add col before binding
      df_box_melt$chart <- "Billboard"
      df_box_melt_non_chart$chart <- "Non Billboard"
      df_boxplot <- rbind(df_box_melt,df_box_melt_non_chart)
      ggplot(df_boxplot %>% filter(chart %in% billboard)) + geom_boxplot(aes(x=year, y=value, fill=variable)) + theme(axis.text.x = element_text(angle=90)) + ylim(0,1)  + facet_grid(. ~ chart)
    }
  }
  
  output$attributes_time <- renderPlot({
    attributes_time(chart_df, nonchart_df, input$attributes, input$boxplot, input$timerange, input$billboard)
  })

}

# Run the application 
shinyApp(ui = ui, server = server)

