#' Add a song to your existing database
#'
#' @param database a dataframe containing music data
#' @param song a new song pulled from an API
#'
#' @return the dataframe with another row, containing the song
#'
#' @examples
#' \dontrun{
#' add_a_song(spotify_track_data,song)
#' }
add_a_song <- function(database,song){
  new_song <- database[1,]
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
  #new_song_new_order <- new_song[,c(2,1)]
  database_modif <- rbind(database_modif,new_song)
  print("succesfully added a song")
  return(database_modif)
}
