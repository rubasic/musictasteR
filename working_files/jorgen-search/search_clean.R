library(shiny)
library(spotifyr)
library(stringr)
library(tidyverse)
library(httr)
source("get_tracks_artists.R")

ui <- shinyUI(fluidPage(
  sidebarLayout(
    sidebarPanel(
      textInput("track", "Search for a track and/or an artist"),
      htmlOutput("albumImage"),
      checkboxGroupInput("selectTracks", label = "Select tracks", choices = NULL),
      actionButton("addTracks", label = "Add tracks"),
      actionButton("clearTracks", label = "Clear tracks")
    ),
    
    # Displaying the output data frame
    # Remove for final Shiny
    mainPanel(
      tableOutput("masterDF")
    )
  )
))

server <- shinyServer(function(input, output, session) {
  
  # Get Spotify access token 
  Sys.setenv(SPOTIFY_CLIENT_ID = 'a98864ad510b4af6851331638eec170f')
  Sys.setenv(SPOTIFY_CLIENT_SECRET = '6445326414dd4bf381afbc779b182223')
  access_token <- get_spotify_access_token()
  
  # Pulling list of tracks from Spotify
  tracks <- reactive({
    req(input$track)
    get_tracks_artists(track_artist_name = input$track, access_token = access_token)
  })
  
  # Displaying album image of first match
  output$albumImage <- renderUI({
    if(length(tracks()$album_img[1]) != 0) {
      image_url <- tracks()$album_img[1]
      tags$img(src = image_url, height = 200, width = 200)
    }
  })
  
  # Updating the checkboxes with top five matches
  observeEvent(input$track, {
    choices <- paste(tracks()$track_artist_name, tracks()$artist_name, sep = " - ")
    updateCheckboxGroupInput(
      session = session, inputId = "selectTracks", 
      choices = choices[1:5])
  })
  
  # Creating a master data frame that whill hold all information about the tracks selected and added by the user
  master_df <- data_frame()
  
  observeEvent(input$addTracks, {
    filtered_tracks <- tracks() %>% filter(track_artist %in% input$selectTracks)
    filtered_tracks_unique <- subset(filtered_tracks, !duplicated(filtered_tracks[,1]))
    track_features <- get_track_audio_features(tracks(), access_token = access_token)
    tracks_joined <- left_join(x = filtered_tracks_unique, y = track_features, by = "track_uri")
    master_df <<- bind_rows(master_df, tracks_joined)
    
    # Displaying the output data frame
    # Remove for final Shiny
    output$masterDF <- renderTable({
      master_df
    })
  })
  
  # Clearing the data frame with saved tracks
  observeEvent(input$clearTracks, {
    master_df <<- tibble()
    output$masterDF <- renderTable({
      master_df
    })
  })

})

# Run app
shinyApp(ui = ui, server = server)

