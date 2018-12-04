
#' Title
#'
#' @param df a dataframe containing one column "year"
#' @param vars attributes to be plotted
#' @param boxplot a boolean (T/F)
#' @param timerange a vector of integers (years to be plotted over)
#'
#' @return a plot
#' @export
#' @import magrittr
#' @import dplyr
#' @importFrom reshape melt
#' @import ggplot2
#' @importFrom stats aggregate
#' @examples
#' plot_time_avg(df, c("danceability","valence"),FALSE,2010:2015)
plot_time_avg <- function(df, vars, boxplot, timerange) {
  df <- as.data.frame(df)
  if(boxplot == FALSE) {
    # get mean for each attribute
    df_avg <- aggregate(df()[,vars], list(df$year), mean)
    colnames(df_avg)[1] <- "year"
    # reshape function for plot
    df_melt <- melt(as.data.frame(df_avg), id = "year")
    # year should be continuous
    df_melt$year <- as.numeric(as.character(df_melt$year))
    ggplot(df_melt, aes(x=year, y=value, color=variable)) + ylim(0,1)  + geom_line(size=1) + xlim(input$timerange)
  }
  else {
    df_time <- as.data.frame(df) %>% filter(year %in% timerange[1]:timerange[2])
    df_box_melt <- melt(df_time,id.vars="year", measure.vars=vars)
    ggplot(df_box_melt) + geom_boxplot(aes(x=year, y=value, fill=variable)) + theme(axis.text.x = element_text(angle=90)) + ylim(0,1)
  }
}
