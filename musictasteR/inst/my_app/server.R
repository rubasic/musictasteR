library(musictasteR)
library(shiny)
library(billboard)
library(spotifyr)
library(tidyverse)
library(httr)
library(reshape)
library(shinythemes)
library(shinyWidgets)
library(shinycssloaders)
library(data.table)
data(averagesongs)

# Set Spotify API credentials
Sys.setenv(SPOTIFY_CLIENT_ID = 'a98864ad510b4af6851331638eec170f')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '6445326414dd4bf381afbc779b182223')


shinyServer(function(input, output,session) {

  # Get Spotify API access token
  access_token <- reactive({
    spotifyr::get_spotify_access_token()
  })

  tracks <- reactive({
    req(input$track)
    # Pulling track information from Spotify
    get_tracks_artists(track_artist_name = input$track, access_token = access_token())
  })

  # Displaying the album image of the first match from the search
  output$albumImage <- renderUI({
    if(length(tracks()$album_img[1]) != 0) {
      image_url <- tracks()$album_img[1]
      tags$img(src = image_url)
    }
  })

  # Updating the checkboxes with top 5 matches from the search
  observeEvent(input$track, {
    if(input$track == "") {
      shinyWidgets::updateAwesomeCheckboxGroup(
        session = session, inputId = "selectTracks",
        choices = character(0))
    }
    choices <- paste(tracks()$track_artist_name, tracks()$artist_name, sep = " - ")
    shinyWidgets::updateAwesomeCheckboxGroup(
      session = session, inputId = "selectTracks",
      choices = choices[0:min(5,length(choices))], inline = TRUE)
  })

  # Creating a master data frame that whill hold all information about the tracks selected and added by the user
  master_df <- data_frame()

  # Creating a data frame that will hold formatted songs for attributes plot
  # Contains "Oops!... I Did It Again" by Britney Spears by default, which is removed when user adds new songs
  new_music <- spotify_track_data %>% filter(artist_name=="Britney Spears") %>% filter(dplyr::row_number()==1)

  # Creating a data frame that will hold formatted songs for logistic regression
  new_music_logit <- data_frame()

  observeEvent(input$addTracks, {

    ## Updating the master dataframe
    # Filtering the search results based on the tracks the user has selected
    filtered_tracks <- tracks() %>% filter(track_artist %in% input$selectTracks)

    # Removing duplicate tracks
    filtered_tracks_unique <- subset(filtered_tracks, !duplicated(filtered_tracks[,1]))

    # Pulling audio features for the selected tracks from Spotify
    track_features <- get_track_audio_features(tracks(), access_token = access_token())

    # Merging the track information and the audio features
    tracks_joined <- left_join(x = filtered_tracks_unique, y = track_features, by = "track_uri")

    # Adding the merged data frame to the master data frame
    master_df <<- bind_rows(master_df, tracks_joined)

    # Preventing user from adding same song twice
    master_df <<- unique(master_df)

    ## Updating the tab "Your songs"
    output$masterDF <- DT::renderDataTable({
      master_df_selected <- master_df %>% select(track_artist_name, artist_name, album_name, release_date)
      colnames(master_df_selected) <- c("Track", "Artist", "Album", "Release date")
      master_df_selected
    })

    ## Updating the table with added songs in the sidebar
    output$yourTracks <- renderTable({
      unique(master_df %>% select(track_artist))
    }, colnames = FALSE)

    ## Updating the data frame with formatted data for logistic regression
    new_music_logit <<- format_new_songs_logit(master_df)

    ## Updating the data frame with formatted data for attributes plot
    new_music <<- format_new_songs(master_df)

    ## Updating the attributes plot
    output$plot <- plotly::renderPlotly({
      p <- hover_plot_shiny(new_music, input$x,input$y,input$year)
    })

    ## Updating cluster plot
    output$plot_cluster <- plotly::renderPlotly({
      plot_songs_clusters(master_df,input$year_cluster)
    })

    ## Updating checkbox choices for logistic regression
    choicez <- unique(master_df$track_artist_name)
    shinyWidgets::updateAwesomeCheckboxGroup(
      session = session, inputId = "selectLogit",
      choices = choicez, selected = choicez[1])
  })

  ## Clearing the songs the user has added
  observeEvent(input$clearTracks, {
    ## Replacing the master data frame with an empty data frame
    master_df <<- data_frame()
    empty <- data_frame()

    ## Updating the tab "Your songs"
    output$masterDF <- DT::renderDataTable({
      empty
    })

    ## Updating the table with added songs in the sidebar
    output$yourTracks <- renderTable({
      empty
    })

    ## Clearing checkbox
    choices <- character(0)
    shinyWidgets::updateAwesomeCheckboxGroup(
      session = session, inputId = "selectLogit",
      choices = choices, selected = NULL)
  })

  ## Updating logistic regression plot
  observeEvent(input$updateLogit, {
    req(input$selectLogit)
    if(nrow(master_df) == 0) {
      print(" ")
    } else {
    logit_input <- new_music_logit %>% split(.$track_name) %>%
      map_df(function(x) {return(get_probability_of_billboard(x, log_model_list)) })
    logit_input <- logit_input %>% filter(track_name %in% input$selectLogit)
    output$plot_logit <- renderPlot(
      plot_probabilities(logit_input, 3, 2, 4, 5))
    }
  })

  ## Attributes plot
  output$plot <- plotly::renderPlotly({
    p <- hover_plot_shiny(new_music, input$x,input$y,input$year)
  })

  ## Cluster plot
  output$plot_cluster <- plotly::renderPlotly({
      plot_songs_clusters(new_music,input$year_cluster)
  })

  ## Historical data plot
  music_dataframe <- billboard::spotify_track_data # Historical Billboard data
  # zAll the Spotify audio attributes
  all_attributes <- c("Danceability" = "danceability" ,"Energy" = "energy",  "Speechiness"  = "speechiness","Acousticness" = "acousticness", "Instrumentalness" = "instrumentalness" ,"Liveness" = "liveness","Valence" = "valence")
  output$attributes_time <- renderPlot({
    req(input$attributes)
    attributes_time(music_dataframe, "Billboard", 1, averagesongs,
                    "Non Billboard", 4, input$attributes, input$boxplot,
                    input$timerange, input$billboard)
  })

})
