#' Hover Plot
#'
#' @param database the database containing musical data you want to analyze. We suggest the billboard::spotify_track_data
#' @param year_col a column of your df containing the years
#' @param filtered_year a string, the year you want to look at
#' @param x_axis a column of your df, the first dimension you want to plot against - such as energy
#' @param y_axis a column of your df, the second dimension you want to plot against - such as danceability
#' @param track_name a column of your df, information 1 you want to displayed when hovering - such as track_name
#' @param artist_name a column of your df, information 2 you want to displayed when hovering - such as artist_name
#' @param title a string, the title of your plot
#'
#' @return a plot
#' @export
#'
#' @import dplyr
#' @import graphics
#' @import glue
#' @import plotly
#' @import ggplot2
#'
#'
#'
#' @examples
#' \dontrun{
#' hover_plot(billboard::spotify_track_data,"1999",energy,danceability,track_name,artist_name,"Charts")
#' }
hover_plot <- function(database,filtered_year,year_col,x_axis,y_axis,track_name = track_name, artist_name = artist_name,title="Billboard Top 100 musical charts of "){
  #enquo all the columns that we need to use
  x_axis <- enquo(x_axis)
  y_axis <- enquo(y_axis)
  artist_name <- enquo(artist_name)
  track_name <- enquo(track_name)

  tracklist <- database %>% filter(year_col == filtered_year | year_col == "0" ) %>%
    select(year_col,!!artist_name,!!track_name,!!x_axis,!!y_axis)

  plot <- ggplot(tracklist, aes(!!x_axis, !!y_axis))  +
    geom_point(aes(Trackname = (!!track_name), Artist= (!!artist_name), size = 0.1),alpha = 1/2) +
    ggtitle(glue::glue("{title}{filtered_year}")) +
    theme_minimal() +xlim(0,1) + ylim (0,1)

  plot_with_hover <- ggplotly(plot) %>% config(displayModeBar = F) %>% layout(xaxis=list(fixedrange=TRUE)) %>% layout(yaxis=list(fixedrange=TRUE)) %>%  layout(hoverlabel = list(bgcolor = "white",font = list(family = "sans serif",size = 12, color = "black")))

  return(plot_with_hover)
}
