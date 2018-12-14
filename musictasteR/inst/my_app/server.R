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



plot_probabilities <- function(input_dataframe, year_int_col_index, prob_col_index, track_name_col_index,  true_song_year_index) {
  #dataframe with year and probability
  colnames(input_dataframe)[year_int_col_index] <-"year_int"
  colnames(input_dataframe)[prob_col_index] <-"prob"
  colnames(input_dataframe)[track_name_col_index] <-"track_name"
  colnames(input_dataframe)[true_song_year_index] <- "true_song_year"
  input_dataframe['true_song_year_bool'] <- input_dataframe$true_song_year == input_dataframe$year_int

  DT <- data.table(input_dataframe)

  #line graph of all the probabilities plotted across time
  g <- ggplot(input_dataframe)+
    geom_line(aes(x=input_dataframe$year_int, y=as.double(input_dataframe$prob),group =input_dataframe$track_name, color=input_dataframe$track_name))+
    theme(legend.position="bottom", legend.direction="vertical")+
    labs(x='year',y='probability', title='Probability of being a top song', legend='tracks')+
    guides(size = "none",color=guide_legend("Track Name"), alpha="none")

  print(max(input_dataframe$true_song_year_bool))

  #highlight actual release year of the song
  if (max(input_dataframe$true_song_year_bool) == 1) {
    g <- g + geom_point(data=input_dataframe[input_dataframe$true_song_year_bool == T,],
                        aes(x=input_dataframe[input_dataframe$true_song_year_bool == T,]$year_int,
                            y=input_dataframe[input_dataframe$true_song_year_bool == T,]$prob
                        ), color="black", size=4)
    g <- g+ geom_text(data=input_dataframe[input_dataframe$true_song_year_bool == T,], aes(x=year_int,y=prob,label=paste0("release year: ", year_int) , alpha=0.8), hjust=-.06,vjust=-.06, size=3)
  }

  #highlight the point with minimum probability of song
  g <- g + geom_point(data=DT[ , .SD[which.min(prob)], by = track_name],
                      aes(x=DT[ , .SD[which.min(prob)], by = track_name]$year_int,
                          y=DT[ , .SD[which.min(prob)], by = track_name]$prob), color="red", shape=25,size=4)

  #highlight the point with maximum probability of the song
  g <- g + geom_point(data=DT[ , .SD[which.max(prob)], by = track_name],
                      aes(x=DT[ , .SD[which.max(prob)], by = track_name]$year_int,
                          y=DT[ , .SD[which.max(prob)], by = track_name]$prob), color="blue", shape=17, size=4)
  g <- g+ geom_text(data=DT[ , .SD[which.min(prob)]], aes(x=year_int,y=prob, label=paste0("min. probability year: ", year_int) ,alpha=0.8), hjust=-.06,vjust=-.06, size=3)
  g <- g+ geom_text(data=DT[ , .SD[which.max(prob)]], aes(x=year_int,y=prob,label=paste0("max. probability year: ", year_int) ,alpha=0.8), hjust=-.06,vjust=-.06, size=3)

  return(g)
}

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

  if (nrow(songs)!=0) {

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





    songs_edit <- predict_pc_lm(songs,year_taken,dim_pc_1,dim_pc_2)
    songs_edit$cluster_final <- "Manual Input songs"
    songs_edit <- songs_edit %>% select(track_name,artist_name,dim_1,dim_2,cluster_final)
  }

  #Test years for 2 samples
  temp <- bb_data %>% filter(year!=1983) %>% filter(year!=2000)
  temp1 <- bb_data %>% filter(year==1985)
  temp1$year=1983
  temp2 <- bb_data %>% filter(year==1997)
  temp2$year=2000
  restr <- rbind(temp,temp1,temp2)

  restr <- restr %>% filter(year==year_taken)
  restr$cluster_final <- paste0("Cluster ",substr(restr$hcpc_pca_cluster,6,7))
  restr <- restr %>% select(track_name,artist_name,dim_1,dim_2,cluster_final)

  if (nrow(songs)!=0) {
    combined <- rbind(restr,songs_edit)
  }
  if (nrow(songs)==0) {
    combined <- restr
  }
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

  # Creating a data frame that will hold formatted songs for attributes plot
  # Contains "Oops!... I Did It Again" by Britney Spears by default, which is removed when user adds new songs
  new_music <- spotify_track_data %>% filter(artist_name=="Britney Spears") %>% filter(dplyr::row_number()==1)

  # Creating a data frame that will hold formatted songs for logistic regression
  new_music_logit <- data_frame()
  bb <- billboard::spotify_track_data[1,]

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

  ## When user pulls the "boxplot" switch, the only attribute that is checked is "danceability"
  observe({
   if(input$boxplot == TRUE) {
     updateCheckboxGroupInput(session = session,
                              inputId = "attributes", selected = "danceability",
                              choices = all_attributes)
     }
    })
})
