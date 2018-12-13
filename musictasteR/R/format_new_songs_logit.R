#' Format New Songs Logit
#' Is a function that prepares musical data from spotify to be fit into the prediction function of this App
#'
#' @param songs a dataframe containing music information
#'
#' @return a dataframe containing music information in a different format
#' @export
#' @import billboard
#'
#' @examples
#' \dontrun{
#' format_new_songs_logit(tracks_from_spotify)
#' }
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
