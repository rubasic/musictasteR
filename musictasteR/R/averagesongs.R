#' Average songs
#'
#' A dataset containing the average songs from 1960-2018
#'
#' @format A data frame with 150425 rows and 23 variables. Each song has several attributes (from Spotify API):
#' \describe{
#'   \item{track_name}{string: name of the track}
#'   \item{track_uri}{string: the Spotify URI for the track}
#'   \item{album_name}{string: name of the album}
#'   \item{year}{int: year of the album}
#'   \item{danceability}{float: measure from 0-1, how suitable a track is for dancing.}
#'   \item{energy}{float: measure from 0-1, general measure of intensity (fast/loud/noisy).}
#'   \item{key}{feature between 0-1}
#'   \item{loudness}{float: overall loudness of a track in dB, measure from -60:0.}
#'   \item{mode}{modality of a track: (major=1 and minor=0)}
#'   \item{speechiness}{float: measure from 0-1, detects the presence of words in a track}
#'   \item{acousticness}{float:	measure from 0.0 to 1.0, confidence of whether the track is acoustic.}
#'   \item{instrumentalness}{float: measure from 0 to 1, predicts whether a track contains no vocals.}
#'   \item{liveness}{float: measure from 0-1, detects the presence of an audience.}
#'   \item{valence}{float: measure from 0-1, describes the musical positiveness conveyed by a track}
#'   \item{tempo}{float: overall estimated tempo in BPM.}
#'   \item{type}{string: the object type: "audio_features".}
#'   \item{uri}{string: the Spotify URI for the track.}
#'   \item{track_href}{string: link to the Web API endpoint providing full details of the track.}
#'   \item{analysis_url}{string: HTTP URL to access the full audio analysis of this track.}
#'   \item{duration_ms}{int: duration of the track in milliseconds}
#'   \item{time_signature}{int: estimated overall time signature of a track.}
#'   \item{artist_name}{string: name of the artist}
#'   \item{artist_id}{string: id of the artist}
#' }

"averagesongs"
