#' Get information about tracks from Spotify
#'
#' This functions takes a string and returns a data frame with track information for 20 songs
#' from Spotify's search endpoint
#' @param track_artist_name A string with track name or an artist name
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords track artist spotify search
#' @export
#' @examples
#' \dontrun{
#' #### Get track information for the top 20 Spotify matches for "Thriller"
#' thriller <- get_tracks_artists(track_artist_name = "Thriller")
#' }

get_tracks_artists <- function(track_artist_name, access_token = get_spotify_access_token()) {

  # Search Spotify API
  res <- GET('https://api.spotify.com/v1/search',
             query = list(q = track_artist_name,
                          type = 'track,artist',
                          access_token = access_token)
  ) %>% content

  if (length(res$tracks$items) >= 0) {

    # res <- res %>% .$tracks %>% .$items

    tracks <- map_df(seq_len(length(res)), function(x) {
      list(
        track_artist_name = res$tracks$items[[x]]$name,
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

  return(tracks)
}
