library(shiny)
library(spotifyr)
library(stringr)
library(DT)
library(tidyverse)
library(httr)
source('R/get_tracks.R')

ui <- shinyUI(fluidPage(
  
  titlePanel("Search Spotify"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("track", "0. Name a track"),
      htmlOutput("albumImage"),
      textInput("artist", "1. Name an artist:"),
      htmlOutput("artistImage"),
      selectInput("selectArtist", label = "2. Choose an artist", choices = NULL),
      selectInput("selectTrack", label = "3. Select a track", choices = NULL)
    ),
    
    mainPanel(
      h3("Artists matching your search"),
      tableOutput("artistTable"),
      tableOutput("trackTable")
    )
  )
))

server <- shinyServer(function(input, output, session) {
  
  # Get access token 
  Sys.setenv(SPOTIFY_CLIENT_ID = 'a98864ad510b4af6851331638eec170f')
  Sys.setenv(SPOTIFY_CLIENT_SECRET = '6445326414dd4bf381afbc779b182223')
  access_token <- get_spotify_access_token()
  
  # Pulling list of artists from Spotify 
  artists <- reactive({
    req(input$artist)
    get_artists(artist_name = input$artist, access_token = access_token) 
  })
  
  # Pulluing list of tracks from Spotify
  tracks <- reactive({
    req(input$track)
    if(!is.null(input$artist)) {
      get_tracks(track_name = input$track, artist_name = input$artist, access_token = access_token)
    }            
    get_tracks(track_name = input$track, access_token = access_token)
  })
  
  # Showing the list of potential matches 
  output$artistTable <- renderTable({
    artists()$artist_name
  },
  colnames = FALSE)
  
  #Showing the list of potential track matches
  output$trackTable <- renderTable({
    tracks() %>% select(track_name, artist_name)
  })
  
  # Showing image of the first potential Track match
  output$albumImage <- renderUI({
    image_url <- tracks()$album_img[1]
    tags$img(src = image_url, height = 200, width = 200)
  })
  
  # Showing image of the first potential Artist match
  output$artistImage <- renderUI({
    image_url <- artists()$artist_img[1]
    tags$img(src = image_url, height = 200, width = 200)
  })
  
  # Updating dropdown manu with potential matches
  observeEvent(input$artist, {
    choices <- artists()$artist_name
    updateSelectInput(session, "selectArtist", choices = choices)
  })
  
})

# Run the application 
shinyApp(ui = ui, server = server)

