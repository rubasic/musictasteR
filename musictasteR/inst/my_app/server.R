library(musictasteR)
library(shiny)
library(ggplot2)
library(billboard)
library(spotifyr)
library(tidyverse)
library(httr)
library(dplyr)

#in the beginning, the user works with the spotify data frame that is then modified once he starts adding songsm
music_dataframe <- billboard::spotify_track_data

new_music <- spotify_track_data %>% filter(artist_name=="Britney Spears") %>% filter(dplyr::row_number()==1)

hover.plot.shiny <- function(data,x,y,chosen_year)
{
  tracklist <- data %>%
    filter(year == chosen_year | year == "your song" ) %>% select(artist_name,year,track_name,x,y)

  plot <- ggplot(tracklist,x=x,y=y) +
    geom_point(aes_string(x=x,y = y,Trackname = as.factor(tracklist$track_name),Artist = as.factor(tracklist$artist_name)),alpha = 0.5) +
    geom_point(data = new_music,
               mapping = aes_string(x = x, y = y,Trackname = as.factor(new_music$track_name),Artist = as.factor(new_music$artist_name)),color="pink") +
    ggtitle(glue::glue("Billboard Top 100 musical charts of {chosen_year}")) +
    theme_minimal() + xlim(0,1) + ylim (0,1)

  hover.plot <- plotly::ggplotly(plot)

 #hover.plot %>% config(displayModeBar = F) %>% layout(xaxis=list(fixedrange=TRUE)) %>% layout(yaxis=list(fixedrange=TRUE)) %>%  layout(hoverlabel = list(bgcolor = "white",
   #                                                                                                                                                               font = list(family = "sans serif",
  #                                                                                                                                                                            size = 12,
    #                                                                                                                                                                         color = "black")));

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
print(master_df)
    # Displaying the output data frame
    # Remove for final Shiny
    output$masterDF <- renderTable({
      master_df
    })
    #View(master_df)
    #call plot to update
    new_music <<- format_new_songs(master_df)
    print(new_music)

    output$plot <- plotly::renderPlotly({
      p <- hover.plot.shiny(billboard::spotify_track_data, input$x,input$y,input$year)
    })


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

 output$plot <- plotly::renderPlotly({
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

