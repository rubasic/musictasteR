#' Title
#'
#' @param input_dataframe the input song has the following attributes: "trackname", "year_int", "prob", "true_song_year"
#' @param year_int_col_index index for year_int col in the dataframe
#' @param prob_col_index index for prob col in the dataframe
#' @param track_name_col_index index for track_name col in the dataframe
#' @param true_song_year_index  index for true song year boolean column
#' @import ggplot2
#' @importFrom data.table data.table
#' @importFrom data.table .SD
#' @return return a ggplot
#' @export
#'
#' @examples
#' \dontrun{
#' plot_probabilities(input_dataframe)
#' }
#'

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

  #highlight actual release year of the song
  g <- g + geom_point(data=input_dataframe[input_dataframe$true_song_year_bool == T,],
                      aes(x=input_dataframe[input_dataframe$true_song_year_bool == T,]$year_int,
                          y=input_dataframe[input_dataframe$true_song_year_bool == T,]$prob
                      ), color="black", size=4)

  #highlight the point with minimum probability of song
  g <- g + geom_point(data=DT[ , .SD[which.min(prob)], by = track_name],
                      aes(x=DT[ , .SD[which.min(prob)], by = track_name]$year_int,
                          y=DT[ , .SD[which.min(prob)], by = track_name]$prob), color="red", shape=25,size=4)

  #highlight the point with maximum probability of the song
  g <- g + geom_point(data=DT[ , .SD[which.max(prob)], by = track_name],
                      aes(x=DT[ , .SD[which.max(prob)], by = track_name]$year_int,
                          y=DT[ , .SD[which.max(prob)], by = track_name]$prob), color="blue", shape=17, size=4)
  g <- g+ geom_text(data=input_dataframe[input_dataframe$true_song_year_bool == T,], aes(x=year_int,y=prob,label=paste0("release year: ", year_int) , alpha=0.8), hjust=-.06,vjust=-.06, size=3)
  g <- g+ geom_text(data=DT[ , .SD[which.min(prob)]], aes(x=year_int,y=prob, label=paste0("min. probability year: ", year_int) ,alpha=0.8), hjust=-.06,vjust=-.06, size=3)
  g <- g+ geom_text(data=DT[ , .SD[which.max(prob)]], aes(x=year_int,y=prob,label=paste0("max. probability year: ", year_int) ,alpha=0.8), hjust=-.06,vjust=-.06, size=3)

  return(g)
}
