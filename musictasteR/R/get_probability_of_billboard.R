#' Get Probability of Song being on Billboard
#'
#' This function gets the probability that a song will be on the billboard charts throughout time
#' @param input_song a named list of all attributes for a song to analyze its probability to be on the billboard charts
#' the input song has the following attributes:
#' "danceability"
#' "energy"
#' "key"
#' "loudness"
#' "mode"
#' "speechiness"
#' "acousticness"
#' "instrumentalness"
#' "liveness"
#' "valence"
#' "tempo"
#' "duration_ms"
#' "artist_name"
#' "track_name"
#' "album_year"
#' @importFrom stats predict
#' @param model The list of logistic regression models that predict probability that a song will be on the billboard charts
#'
#' @return a dataframe containing the probability a song will be on the billboard charts throughout time
#' @export
#'
#' @examples
#' \dontrun{
#' get_probability_of_billboard(input_song)
#' 
#' }

get_probability_of_billboard <- function(input_song, model) {
	list_of_probability <- vector()
	
	for (model_year in names(model)) {
	  model_output <-model[model_year][[1]]
	  song_year <- new_song$album_year
	  probability <- predict(model_output,newdata=new_song,type="response")[[1]]
	  list_of_probability[model_year] <- probability
	}
	df <- data.frame(list_of_probability)
	df <- data.frame(cbind(rownames(df),df$list_of_probability))
	colnames(df) <- c('year', 'prob')
	df['year_int'] <- sapply(df$year,  function(x) {as.integer(substring(x,str_length(x)-3,str_length(x)))})
	return(df)
}