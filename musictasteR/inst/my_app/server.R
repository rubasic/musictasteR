library(musictasteR)
library(shiny)
library(ggplot2)
library(billboard)
library(spotifyr)
library(tidyverse)
library(httr)
library(dplyr)
library(reshape)
library(shinythemes)
data(averagesongs)
library(shinycssloaders)

#in the beginning, the user works with the spotify data frame that is then modified once he starts adding songsm
music_dataframe <- billboard::spotify_track_data

new_music <- spotify_track_data %>% filter(artist_name=="Britney Spears") %>% filter(dplyr::row_number()==1)

hover.plot.shiny <- function(data,x,y,chosen_year)
{
  tracklist <- data %>%
    filter(year == chosen_year) %>% select(artist_name,year,track_name,x,y)

  plot <- ggplot(tracklist,x=x,y=y) +
    geom_point(aes_string(x=x,y = y,Trackname = as.factor(tracklist$track_name),Artist = as.factor(tracklist$artist_name)),color="#00c193",size=4.5,alpha = 0.5) +
    geom_point(data = new_music,
               mapping = aes_string(x = x, y = y,Trackname = as.factor(new_music$track_name),Artist = as.factor(new_music$artist_name)),color="#fd5bda",size=4.5) +
   scale_x_continuous(name=glue::glue("{x}"), limits=c(0, 1))+ scale_y_continuous(name=glue::glue("{y}"), limits=c(0, 1)) +

    theme(text = element_text(size=9),plot.background = element_rect(fill = "#3e444c"))
 # hover.plot <- plotly::ggplotly(plot)
  hover.plot <- plotly::ggplotly(plot) %>% plotly::config(displayModeBar = F) %>%  plotly::layout(hoverlabel = list(bgcolor = "#ebebeb",font = list(family = "Helvetica Neue",
                                                                                                                                                                          size = 14,
                                                                                                                                                                             color = "black")));

  return(hover.plot)
}


## AKSHAY CLUSTER FUNCTION

plot_songs_clusters <- function(songs,year_taken){
  print(songs)
  songs$key <- as.numeric(songs$key)
  songs$mode <- as.numeric(songs$mode)
  colnames(songs)[colnames(songs)=="track_artist_name"]="track_name"
  restr <- bb_data %>% filter(year==year_taken)
  restr$cluster_final <- paste0("Cluster ",substr(restr$hcpc_pca_cluster,6,7))
  songs_edit <- predict_pc_lm(songs,year_taken,dim_pc_1,dim_pc_2)
  songs_edit$cluster_final <- "Manual Input songs"
  songs_edit <- songs_edit %>% select(track_name,artist_name,dim_1,dim_2,cluster_final)
  restr <- restr %>% select(track_name,artist_name,dim_1,dim_2,cluster_final)
  combined <- rbind(restr,songs_edit)
  response <- combined %>% ggplot(aes(x=dim_1,y=dim_2)) + geom_point(aes(col=cluster_final)) + scale_fill_manual(name="Clusters",values = c("Cluster 1"="red","Cluster 2"="cyan","Cluster 3"="magenta","Manual Input songs"="yellow"))
  response_fin <- plotly::ggplotly(response)%>%  plotly::layout(hoverlabel = list(bgcolor = "#ebebeb",font = list(family = "Arial", size = 12, color = "black"))) %>% plotly::config(displayModeBar = F)
  return(response)
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
      tags$img(src = image_url, height = 250, width = 250)
    }
  })

  # output$albumImage2 <- renderUI({
  #   if(length(tracks()$album_img[2]) != 0) {
  #     image_url <- tracks()$album_img[2]
  #     tags$img(src = image_url, height = 200, width = 200)
  #   }
  # })

  # Updating the checkboxes with top five matches
  observeEvent(input$track, {
    choices <- paste(tracks()$track_artist_name, tracks()$artist_name, sep = " - ")
    shinyWidgets::updateAwesomeCheckboxGroup(
      session = session, inputId = "selectTracks",
      choices = choices[0:min(5,length(choices))], inline = TRUE
    )
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
    output$masterDF <- DT::renderDataTable({
      master_df
      # master_dff <- master_df %>% select(track_artist_name, artist_name, album_name,
      #                                    release_date)
      # colnames(master_dff) <- c("Track", "Artist", "Album", "Release date")
      # master_dff
    })

    output$yourTracks <- renderTable({
      master_df %>% select(track_artist)
    }, colnames = FALSE)

    #View(master_df)
    #call plot to update
    new_music <<- format_new_songs(master_df)
    print(new_music)

    output$plot <- plotly::renderPlotly({
      p <- hover.plot.shiny(billboard::spotify_track_data, input$x,input$y,input$year)
    })

    output$plot_cluster <- plotly::renderPlotly({
      plot_songs_clusters(master_df,input$year_cluster)
    })

  })

  # Clearing the data frame with saved tracks
  observeEvent(input$clearTracks, {
    master_df <<- tibble()

    # Displaying the output data frame
    # Remove for final Shiny
    output$masterDF <- DT::renderDataTable({
      master_df
    })

    output$yourTracks <- renderTable(
      master_df
    )
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

 ## CLARA PLOT
 all_attributes <- c("Danceability" = "danceability" ,"Energy" = "energy",  "Speechiness"  = "speechiness","Acousticness" = "acousticness", "Instrumentalness" = "instrumentalness" ,"Liveness" = "liveness","Valence" = "valence")

 observe({
   if(input$boxplot == TRUE) {
     updateCheckboxGroupInput(session = session,
                              inputId = "attributes", selected = "danceability",
                              choices = all_attributes)
   }
 })

 output$attributes_time <- renderPlot({
   attributes_time(music_dataframe, "Billboard", 1, averagesongs,
                   "Non Billboard", 4, input$attributes, input$boxplot,
                   input$timerange, input$billboard)
 })


})
