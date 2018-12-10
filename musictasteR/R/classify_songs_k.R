#' Add a column for songs containing k means cluster for a given year
#'
#'
#' @param song a new song pulled from an API
#' @param year the year to be compared with
#' @param k_model the model for k means clustering
#' @importFrom stats dist
#'
#' @return the dataframe with additional column for cluster
#' @export
#' @examples
#' \dontrun{
#' classify_songs_k(song,year,k_model)
#' }
classify_songs_k <- function(song,year,k_model){

  index_val <- year-1959
  k_model_res <- k_model[index_val][[1]]
  res_song <- song %>% select(dim_1,dim_2)
  clusters <- predict_pc_lm(as.data.frame(k_model_res$centers),2010,dim_pc_1,dim_pc_2) %>% select(dim_1,dim_2)
  class_sort <- data.frame()

  for (i in 1:nrow(song)) {
    temp1 <- res_song[i,]
    dist_mat <- dist(rbind(clusters,temp1))

    if(min(dist_mat[3],dist_mat[5],dist_mat[6])==dist_mat[3]){
      class_sort[i,1] <- 1
    }
    if(min(dist_mat[3],dist_mat[5],dist_mat[6])==dist_mat[5]){
      class_sort[i,1] <- 2
    }
    if(min(dist_mat[3],dist_mat[5],dist_mat[6])==dist_mat[6]){
      class_sort[i,1] <- 3
    }

  }

  song$cluster <- class_sort
  return(song)
}
