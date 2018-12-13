#' Hover Plot Shiny
#'
#' @param data a dataframe containing music data, for example the list of the top 100 songs
#' @param x the first characteristic the music should be plotted against
#' @param y the second characteristic the music should be plotted against
#' @param chosen_year the year for which the songs are shown, between 1960 and 2015 if using the billboard data
#'
#' @return a plotly plot
#' @importFrom plotly ggplotly config layout
#' @importFrom glue glue
#' @importFrom ggplot2 ggplot
#' @examples
#' hover_plot_shiny(billboard_music_dataframe,energy,danceability,"1994")
hover_plot_shiny <- function(data,x,y,chosen_year)
{
  tracklist <- data %>%
    filter(year == chosen_year) %>% select(artist_name,year,track_name,x,y)

  plot <- ggplot(tracklist,x=x,y=y) +
    geom_point(aes_string(x=x,y = y,Trackname = as.factor(tracklist$track_name),Artist = as.factor(tracklist$artist_name)),color="#00c193",size=4.5,alpha = 0.5) +
    geom_point(data = new_music,
               mapping = aes_string(x = x, y = y,Trackname = as.factor(new_music$track_name),Artist = as.factor(new_music$artist_name)),color="#fd5bda",size=4.5) +


    scale_x_continuous(name=glue::glue("{x}"), limits=c(0, 1))+ scale_y_continuous(name=glue::glue("{y}"), limits=c(0, 1)) +
    theme(text = element_text(size=12),plot.background = element_rect(fill = "#f7f7f7"),panel.background = element_rect(fill = "#f7f7f7", colour = "grey50"))

  hover.plot <- ggplotly(plot) %>% config(displayModeBar = F) %>%  layout(hoverlabel = list(font = list(family = "Helvetica Neue",
                                                                                                                                size = 14,
                                                                                                                                color = "black")));

  return(hover.plot)
}
