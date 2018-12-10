
library(musictasteR)
library(plotly)
library(shiny)
library(ggplot2)
library(billboard)
library(spotifyr)
library(tidyverse)
library(httr)

#in the beginning, the user works with the spotify data frame that is then modified once he starts adding songsm
music_dataframe <- spotify_track_data

add.a.song <- function(database,song){
  print(song)
  new_song <- spotify_track_data[1,]
  new_song[1,] <- ""
  new_song$artist_name <- song$track_artist_name
  new_song$track_name <- song$artist_name
  new_song$danceability <- song$danceability
  new_song$energy <- song$energy
  new_song$key <- song$key
  new_song$loudness <- song$loudness
  new_song$mode <- song$mode
  new_song$speechiness<- song$speechiness
  new_song$acousticness <- song$acousticness
  new_song$instrumentalness <- song$instrumentalness
  new_song$liveness <- song$liveness
  new_song$valence <- song$valence
  new_song$tempo <- song$tempo
  new_song$year <- "your song"
  #new_song$real_year <- substr(song$release_date, 1, 4)



  #we copy the database we have into a new dataframe
  database_modif <- database
  #collect the characteristics that we need
  #new_song$year <- 0
  #new_song_new_order <- new_song[,c(2,1)]
  database_modif <- rbind(database_modif,new_song)
  print("succesfully added a song")
  #View(database_modif)
  return(database_modif)
}

hover.plot.shiny <- function(data,x,y,chosen_year)
{
  tracklist <- data %>%
    filter(year == chosen_year | year == "your song" ) %>% select(artist_name,year,track_name,x,y)

  plot <- ggplot(tracklist,x=x,y=y,fill= as.factor(year_col)) + guides(fill= "none") +
    geom_point(aes_string(x=x,y = y,Trackname = as.factor(tracklist$track_name),Artist = as.factor(tracklist$artist_name)),alpha = 0.5) +
    ggtitle(glue::glue("Billboard Top 100 musical charts of {chosen_year}")) +
    theme_minimal() + xlim(0,1) + ylim (0,1)

  hover.plot <- ggplotly(plot)
  # %>% config(displayModeBar = F) %>% layout(xaxis=list(fixedrange=TRUE)) %>% layout(yaxis=list(fixedrange=TRUE)) %>%  layout(hoverlabel = list(bgcolor = "white",
  #                                                                                                                                                                           font = list(family = "sans serif",
  #                                                                                                                                                                                       size = 12,
  #                                                                                                                                                                                       color = "black")));
  return(hover.plot)
}


shinyServer(function(input, output,session) {

##SEARCH FUNCTION

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

  # Adding tracks to the master data frame
  observeEvent(input$addTracks, {

    # Filtering the data frame with track information based on the tracks the user has selected
    filtered_tracks <- tracks() %>% filter(track_artist %in% input$selectTracks)

    # Removing duplicate tracks
    filtered_tracks_unique <- subset(filtered_tracks, !duplicated(filtered_tracks[,1]))

    # Pulling audio features for the selected tracks from Spotify
    track_features <- get_track_audio_features(tracks(), access_token = access_token)

    # Merging the track information and the audio features
    tracks_joined <- left_join(x = filtered_tracks_unique, y = track_features, by = "track_uri")

    # Adding the merged data frame to the master data frame
    master_df <<- bind_rows(master_df, tracks_joined)

    # Displaying the output data frame
    # Remove for final Shiny
    output$masterDF <- renderTable({
      master_df
    })
    #View(master_df)
    #call plot to update
    dataframe_with_new_music <- add.a.song(music_dataframe,master_df)

    reactive.data <- reactiveValues(
      newmusic = dataframe_with_new_music
    )

  })

  # Clearing the data frame with saved tracks
  observeEvent(input$clearTracks, {
    master_df <<- tibble()

    # Displaying the output data frame
    # Remove for final Shiny
    output$masterDF <- renderTable({
      master_df
    })
  })
##END OF SEARCH FUNCTION

  output$plot <- renderPlotly({
    p <- hover.plot.shiny(music_dataframe, input$x,input$y,input$year)
  })


 ' output$event <- renderPrint({
    d <- event_data("plotly_hover")
    if (is.null(d)) {
      "Hover to get information about songs"
    }
    else {
      d
    }
  })'

})

