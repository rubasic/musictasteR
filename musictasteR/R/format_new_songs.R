#' Format the songs that the user inputs into the same format as the billboard top charts
#'
#'
#' @param songs a new song pulled from an API
#' @import billboard
#'
#' @return the dataframe with another row, containing the song
#' @export
#' @examples
#' \dontrun{
#' format_new_songs(songs)
#' }
format_new_songs <- function(songs){
  new_songs <- billboard::spotify_track_data[nrow(songs),]
  new_songs <- ""
  new_songs$artist_name <- songs$artist_name
  new_songs$track_name <- songs$track_artist_name
  new_songs$danceability <- songs$danceability
  new_songs$energy <- songs$energy
  new_songs$key <- songs$key
  new_songs$loudness <- songs$loudness
  new_songs$mode <- songs$mode
  new_songs$speechiness<- songs$speechiness
  new_songs$acousticness <- songs$acousticness
  new_songs$instrumentalness <- songs$instrumentalness
  new_songs$liveness <- songs$liveness
  new_songs$valence <- songs$valence
  new_songs$tempo <- songs$tempo
  new_songs$year <-  substr(songs$release_date, 1, 4)
  return(as.data.frame(new_songs))
}
