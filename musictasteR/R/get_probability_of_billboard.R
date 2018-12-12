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
#' "year"
#' @param model The list of logistic regression models that predict probability that a song will be on the billboard charts
#' @importFrom stats predict
#'
#' @return a dataframe containing the probability a song will be on the billboard charts throughout time
#' dataframe contains three columns: year (formatted as strings: "year<year>"), probability (double) and year_int (integer of year)
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
	  probability <- predict(model_output,newdata=input_song,type="response")[[1]]
	  list_of_probability[model_year] <- probability
	}
	df <- data.frame(list_of_probability, stringsAsFactors = F)
	df <- data.frame(cbind(rownames(df),df$list_of_probability))
	colnames(df) <- c('year', 'prob')
	df['year_int'] <- sapply(df$year,  function(x) {as.integer(substring(x,str_length(x)-3,str_length(x)))})
	df['prob'] <- as.double(df$prob)
	df['track_name'] <-  input_song$track_name
	df['true_song_year'] <- substring(input_song$year, 1,4) #the real year of the song
	return(df)
}
