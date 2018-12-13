#' Return a plot element for a song and a year, in comparison to other billboard tracks in that year
#'
#'
#' @param songs a new song pulled from an API
#' @param year_taken the year to be compared with
#' @import tidyverse
#' @import stringr
#' @importFrom stats dist
#'
#' @return the dataframe with additional column for cluster
#' @export
#' @examples
#' \dontrun{
#' plot_songs_clusters(songs,year_taken)
#' }
plot_songs_clusters <- function(songs,year_taken){

  restr <- bb_data %>% filter(year==year_taken)
  restr$cluster_final <- paste0("Cluster ",substr(restr$hcpc_pca_cluster,6,7))

  songs_edit <- predict_pc_lm(songs,year_taken,dim_pc_1,dim_pc_2)
  songs_edit$cluster_final <- "Your Inputs"

  songs_edit <- songs_edit %>% select(track_name,artist_name,dim_1,dim_2,cluster_final)
  restr <- restr %>% select(track_name,artist_name,dim_1,dim_2,cluster_final)

  combined <- rbind(restr,songs_edit)

  response <- combined %>% ggplot(aes(x=dim_1,y=dim_2)) + geom_point(aes(col=cluster_final)) + scale_fill_manual(name="Clusters",values = c("Cluster 1"="red","Cluster 2"="cyan","Cluster 3"="magenta","Manual Input songs"="yellow"))

  response_fin <- plotly::ggplotly(response)%>%  plotly::layout(hoverlabel = list(bgcolor = "#ebebeb",font = list(family = "Arial", size = 12, color = "black"))) %>% plotly::config(displayModeBar = F)

  return(response_fin)
}
