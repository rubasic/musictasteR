#' Add a column for songs containing k means cluster for a given year
#'
#'
#' @param song a new song pulled from an API
#' @param year the year to be compared with
#' @param k_model the model for k means clustering
#' @import ggplot2
#' @import billboard
#'
#' @return the dataframe with additional column for cluster
#' @export
#' @examples
#' \dontrun{
#' classify_songs_k(song,year,k_model)
#' }
plot_clusters_songs <- function(song,year){

  response1 <- predict_pc_lm(song,year,dim_pc_1,dim_pc_2)


}
