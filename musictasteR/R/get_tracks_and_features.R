#' Get Tracks and Features
#'
#' get_tracks_and_features returns the 20 first matches of a string query to the spotify API.
#' The returned dataframe contains all the characteristics needed to make use of the musictasteR plots
#'
#' @param search_string a string containing a name of the artist or song
#' @param access_token the access token for to the Spotify API
#'
#' @importFrom httr GET content RETRY
#' @return a 23 x 20 dataframe containing the first 20 matches from spotify including music characteristics such as energy, danceability etc.
#' @export
#'
#' @examples
#' get_tracks_and_features("thriller")
get_tracks_and_features <- function(search_string, access_token = get_spotify_access_token()) {

  access_token <- access_token

  # Search Spotify API
  res <- GET('https://api.spotify.com/v1/search',
             query = list(q = search_string,
                          type = 'track,artist',
                          access_token = access_token)
  ) %>% content

  if (length(res$tracks$items) >= 0) {

    tracks <- map_df(seq_len(length(res$tracks$items)), function(x) {
      list(
        search_string = res$tracks$items[[x]]$name,
        track_uri = gsub('spotify:track:', '', res$tracks$items[[x]]$uri),
        artist_name = res$tracks$items[[x]]$artists[[1]]$name,
        artist_uri = res$tracks$items[[x]]$artists[[1]]$id,
        album_name = res$tracks$items[[x]]$album$name,
        album_id = res$tracks$items[[x]]$album$id,
        album_img = res$tracks$items[[x]]$album$images[[1]]$url,
        release_date = res$tracks$items[[x]]$album$release_date,
        track_artist = paste(res$tracks$items[[x]]$name, res$tracks$items[[x]]$artists[[1]]$name, sep = " - ") # Track and artist name combined
      )
    })

  } else {
    tracks <- tibble()
  }

  audio_features <- get_track_audio_features(tracks = tracks, access_token = access_token)

  all_info <- left_join(tracks, audio_features)
}
