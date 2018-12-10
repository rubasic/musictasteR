#' Add columns for songs containing principal dimensions based on pre-created linear models
#'
#'
#' @param song a new song pulled from an API
#' @param year the year to be compared with
#' @param mod1 the model for dimension 1 of PCA
#' @param mod2 the model for dimension 2 of PCA
#'
#' @return the dataframe additional columns for dimensions 1 and 2 ie dim_1,dim_2
#' @export
#' @examples
#' \dontrun{
#' predict_pc_lm(song,year,mod1,mod2)
#' }
predict_pc_lm <- function(song,year,mod1,mod2){
  index_val <- year-1959
  song$dim_1 <- predict(mod1[index_val][[1]],song)
  song$dim_2 <- predict(mod2[index_val][[1]],song)
  return(song)
}
