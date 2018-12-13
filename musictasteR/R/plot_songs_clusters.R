#' Plot Songs Cluster
#'
#' Return a plot element for a song and a year, in comparison to other billboard tracks in that year
#'
#'
#' @param songs a new song pulled from an API
#' @param year_taken the year to be compared with
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

  #Process Columns for Mode and Key
  songs$mode <- ifelse(songs$mode=="Major",1,0)
  songs$key <- case_when(
    songs$key=="C"~0,
    songs$key=="C#"~1,
    songs$key=="Db"~1,
    songs$key=="D"~2,
    songs$key=="D#"~3,
    songs$key=="Eb"~3,
    songs$key=="E"~4,
    songs$key=="F"~5,
    songs$key=="F#"~6,
    songs$key=="Gb"~6,
    songs$key=="G"~7,
    songs$key=="G#"~8,
    songs$key=="Ab"~8,
    songs$key=="A"~9,
    songs$key=="A#"~10,
    songs$key=="Bb"~10,
    songs$key=="B"~11,
    TRUE~-1
  )
  colnames(songs)[colnames(songs)=="track_artist_name"]="track_name"

  #Test years for 2 samples
  temp <- bb_data %>% filter(year!=1983) %>% filter(year!=2000)
  temp1 <- bb_data %>% filter(year==1985)
  temp1$year=1983
  temp2 <- bb_data %>% filter(year==1997)
  temp2$year=2000
  restr <- rbind(temp,temp1,temp2)


  restr <- restr %>% filter(year==year_taken)
  restr$cluster_final <- paste0("Cluster ",substr(restr$hcpc_pca_cluster,6,7))
  songs_edit <- predict_pc_lm(songs,year_taken,dim_pc_1,dim_pc_2)
  songs_edit$cluster_final <- "Manual Input songs"
  songs_edit <- songs_edit %>% select(track_name,artist_name,dim_1,dim_2,cluster_final)
  restr <- restr %>% select(track_name,artist_name,dim_1,dim_2,cluster_final)
  combined <- rbind(restr,songs_edit)
  combined$Primary <- round(combined$dim_1,2)
  combined$Secondary <- round(combined$dim_2,2)
  combined$Group <- combined$cluster_final


  response <- ggplot(combined,aes(x=Primary,y=Secondary,col=Group)) +
    geom_point(aes_string(Trackname = as.factor(combined$track_name),Artist = as.factor(combined$artist_name)),size=2.5,alpha = 0.5) +
    scale_x_continuous(limits=c(-5, 5))+ scale_y_continuous(limits=c(-5, 5)) +
    theme(text = element_text(size=12),plot.background = element_rect(fill = "#f7f7f7"),panel.background = element_rect(fill = "#f7f7f7", colour = "grey50"))

  response_fin <- plotly::ggplotly(response) %>%
    plotly::config(displayModeBar = F) %>%  plotly::layout(hoverlabel = list(font = list(family = "Helvetica Neue",
                                                                                         size = 14,
                                                                                         color = "black")));
  return(response_fin)
}
