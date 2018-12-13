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


format_new_songs_logit <- function(songs){
  new_songs <- billboard::spotify_track_data[nrow(songs),]
  new_songs <- ""
  new_songs$artist_name <- songs$artist_name
  new_songs$track_name <- songs$track_artist_name
  new_songs$duration_ms <- songs$duration_ms
  new_songs$danceability <- songs$danceability
  new_songs$energy <- songs$energy
  new_songs$key <- case_when(
    songs$key=="C"~0,
    songs$key=="C#"~1,
    songs$key=="Db"~1,
    songs$key=="D"~2,
    songs$key=="D#"~3,
    songs$key=="Eb"~3,
    songs$key=="E"~4,
    songs$key=="F"~5,
    songs$key=="F#"~6,
    songs$key=="Gb"~6,
    songs$key=="G"~7,
    songs$key=="G#"~8,
    songs$key=="Ab"~8,
    songs$key=="A"~9,
    songs$key=="A#"~10,
    songs$key=="Bb"~10,
    songs$key=="B"~11,
    TRUE~-1)
  new_songs$loudness <- songs$loudness
  new_songs$mode <- ifelse(songs$mode=="Major",1,0)
  new_songs$speechiness<- songs$speechiness
  new_songs$acousticness <- songs$acousticness
  new_songs$instrumentalness <- songs$instrumentalness
  new_songs$liveness <- songs$liveness
  new_songs$valence <- songs$valence
  new_songs$tempo <- songs$tempo
  new_songs$year <-  substr(songs$release_date, 1, 4)
  return(as.data.frame(new_songs))
}
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
    theme(text = element_text(size=12),plot.background = element_rect(fill = "#f7f7f7"),panel.background = element_rect(fill = "#f7f7f7", colour = "grey50"))

  hover.plot <- plotly::ggplotly(plot) %>% plotly::config(displayModeBar = F) %>%  plotly::layout(hoverlabel = list(font = list(family = "Helvetica Neue",
                                                                                                                                size = 14,
                                                                                                                                color = "black")));

  return(hover.plot)
}


## AKSHAY CLUSTER FUNCTION

plot_songs_clusters <- function(songs,year_taken){

  #Process Columns for Mode and Key
  songs$mode <- ifelse(songs$mode=="Major",1,0)
  songs$key <- case_when(
    songs$key=="C"~0,
    songs$key=="C#"~1,
    songs$key=="Db"~1,
    songs$key=="D"~2,
    songs$key=="D#"~3,
    songs$key=="Eb"~3,
    songs$key=="E"~4,
    songs$key=="F"~5,
    songs$key=="F#"~6,
    songs$key=="Gb"~6,
    songs$key=="G"~7,
    songs$key=="G#"~8,
    songs$key=="Ab"~8,
    songs$key=="A"~9,
    songs$key=="A#"~10,
    songs$key=="Bb"~10,
    songs$key=="B"~11,
    TRUE~-1
  )
  colnames(songs)[colnames(songs)=="track_artist_name"]="track_name"

  #Test years for 2 samples
  temp <- bb_data %>% filter(year!=1983) %>% filter(year!=2000)
  temp1 <- bb_data %>% filter(year==1985)
  temp1$year=1983
  temp2 <- bb_data %>% filter(year==1997)
  temp2$year=2000
  restr <- rbind(temp,temp1,temp2)


  restr <- restr %>% filter(year==year_taken)
  restr$cluster_final <- paste0("Cluster ",substr(restr$hcpc_pca_cluster,6,7))
  songs_edit <- predict_pc_lm(songs,year_taken,dim_pc_1,dim_pc_2)
  songs_edit$cluster_final <- "Manual Input songs"
  songs_edit <- songs_edit %>% select(track_name,artist_name,dim_1,dim_2,cluster_final)
  restr <- restr %>% select(track_name,artist_name,dim_1,dim_2,cluster_final)
  combined <- rbind(restr,songs_edit)
  combined$Primary <- round(combined$dim_1,2)
  combined$Secondary <- round(combined$dim_2,2)
  combined$Group <- combined$cluster_final


  response <- ggplot(combined,aes(x=Primary,y=Secondary,col=Group)) +
    geom_point(aes_string(Trackname = as.factor(combined$track_name),Artist = as.factor(combined$artist_name)),size=2.5,alpha = 0.5) +
    scale_x_continuous(limits=c(-5, 5))+ scale_y_continuous(limits=c(-5, 5)) +
    theme(text = element_text(size=12),plot.background = element_rect(fill = "#f7f7f7"),panel.background = element_rect(fill = "#f7f7f7", colour = "grey50"))

  response_fin <- plotly::ggplotly(response) %>%
    plotly::config(displayModeBar = F) %>%  plotly::layout(hoverlabel = list(font = list(family = "Helvetica Neue",
                                                                                         size = 14,
                                                                                         color = "black")));
  return(response_fin)
}

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
      tags$img(src = image_url, height = 250, width = 250)
    }
  })

  # Updating the checkboxes with top 5 matches from the search
  observeEvent(input$track, {
    choices <- paste(tracks()$track_artist_name, tracks()$artist_name, sep = " - ")
    shinyWidgets::updateAwesomeCheckboxGroup(
      session = session, inputId = "selectTracks",
      choices = choices[0:min(5,length(choices))], inline = TRUE)
  })

  # Creating a master data frame that whill hold all information about the tracks selected and added by the user
  master_df <- data_frame()

  # Creating a data frame that will hold formatted songs for logistic regression
  songs_logit <- data_frame()

  #
  observeEvent(input$addTracks, {
    req(input$track)

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
    songs_logit <<- format_new_songs_logit(master_df)

    output$plot <- plotly::renderPlotly({
      p <- hover.plot.shiny(billboard::spotify_track_data, input$x,input$y,input$year)
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

  ## Updating logistic regression plot
  observeEvent(input$updateLogit, {
    req(input$selectLogit)
    input_song_df <- songs_logit %>% split(.$track_name) %>%
      map_df(function(x) {return(get_probability_of_billboard(x, log_model_list)) })
    input_song_df <- input_song_df %>% filter(track_name %in% input$selectLogit)
    output$plot_logit <- renderPlot(
      plot_probabilities(input_song_df, 3, 2, 4, 5)
    )
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


  #default plots
 output$plot <- plotly::renderPlotly({
    p <- hover.plot.shiny(music_dataframe, input$x,input$y,input$year)
  })

 output$plot_cluster <- plotly::renderPlotly({
   plot_songs_clusters(new_music,input$year_cluster)
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
   req(input$attributes)
   attributes_time(music_dataframe, "Billboard", 1, averagesongs,
                   "Non Billboard", 4, input$attributes, input$boxplot,
                   input$timerange, input$billboard)
 })


})
