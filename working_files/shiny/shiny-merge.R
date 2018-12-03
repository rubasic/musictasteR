all_attributes <- c("explicit", "danceability" ,"energy" ,"mode", "speechiness","acousticness", "instrumentalness" ,"liveness","valence" ,"tempo")

# Define UI for application that draws a histogram
ui <- fluidPage(
  tabsetPanel(
  tabPanel("Song Attributes over Time",
           #titlePanel(),
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
  ),
  tabPanel("This is a test")
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
  #function for getting id
  get_id <- function(track_name, artist_name) {
    track_name = gsub(' ','%20',gsub("[^[:alnum:][:space:]]",'',track_name))
    artist_name =gsub(' ','%20',gsub("[^[:alnum:][:space:]]",'',artist_name))
    api <- str_glue('https://api.spotify.com/v1/search/?q=track:{track_name}%20artist:{artist_name}&type=track&limit=1')
    result <- RETRY('GET', url = api, query = list(access_token = access_token), quiet = TRUE, times = 1) %>% content 
    try(return(result$tracks$items[[1]]$id))
    # try(return(result))
  }

  df <- billboard::spotify_track_data
   # install.packages("prenoms")

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

