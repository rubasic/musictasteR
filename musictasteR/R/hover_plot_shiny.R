#' Hover Plot Shiny
#'
#' Hover Plot Shiny is a function that allows you to plot your favorite song against the top billboard charts from 1960 - 2015.
#' @param new_music a dataframe
#' @param x a column name of the billboard data frame the first characteristic the music should be plotted against
#' @param y a column name of the billboard data frame the second characteristic the music should be plotted against
#' @param chosen_year the year for which the songs are shown, between 1960 and 2015 if using the billboard data
#'

#' @importFrom plotly ggplotly config layout
#' @importFrom glue glue
#' @importFrom ggplot2 ggplot
#'
#' @return a plotly plot showing the top billboard charts filtered by year, plotted against x and y, and the songs added by the user
#' @export
#' @examples
#' \dontrun{
#' hover_plot_shiny(new_music,energy,danceability,"1994")
#' }
hover_plot_shiny <- function(new_music,x,y,chosen_year)
{
  tracklist <- billboard::spotify_track_data %>%
    filter(year == chosen_year) %>% select(artist_name,year,track_name,x,y)

  plot <- ggplot(tracklist,x=x,y=y) +
    geom_point(aes_string(x=x,y = y,Trackname = as.factor(tracklist$track_name),Artist = as.factor(tracklist$artist_name)),color="#00c193",size=4.5,alpha = 0.5) +
    geom_point(data = new_music,
               mapping = aes_string(x = x, y = y,Trackname = as.factor(new_music$track_name),Artist = as.factor(new_music$artist_name)),color="#fd5bda",size=4.5) +


    scale_x_continuous(name=glue::glue("{x}"), limits=c(0, 1))+ scale_y_continuous(name=glue::glue("{y}"), limits=c(0, 1)) +
    theme(text = element_text(size=12),plot.background = element_rect(fill = "#f7f7f7"),panel.background = element_rect(fill = "#f7f7f7", colour = "grey50"))

  hover.plot <- plotly::ggplotly(plot) %>% plotly::config(displayModeBar = F) %>%  plotly::layout(hoverlabel = list(font = list(family = "Helvetica Neue",
                                                                                                                                size = 14,
                                                                                                                                color = "black")));

  return(hover.plot)
}
