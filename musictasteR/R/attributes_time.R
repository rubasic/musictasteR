#' Plot Attributes Over Time
#'
#' This function plots the features of 2 different datasets (in dataframes) over time in the same graph.
#' The dataframes should have overlapping features and contain a column "year" over which these features will be plotted.
#' An example of 2 datasets are: top songs & average songs with "danceability" and "energy" attributes over years 1990 to 2010.
#'
#'
#' @param df1 a data.frame
#' @param df1_title title of your first df (ex: topsongs)
#' @param df1_year_col a number (column number of the "year" column)
#' @param df2 a data.frame
#' @param df2_title title of your second df (ex: averagesongs)
#' @param df2_year_col a number (column number of the "year" column)
#' @param attributes a vector containing strings (names of columns to be plotted, ex: c("energy","danceability"))
#' @param boxplot a boolean (TRUE = plot as boxplot, FALSE = plot as averages)
#' @param timerange a 2x1 vector (years to be plotted over, ex: c(1990, 2010))
#' @param title_vector a string vector with df title names, defines what will be plotted (ex: c(df1_title) will plot only the first dataframe, c(df1_title, df2_title) will plot both)
#' @importFrom reshape melt
#' @importFrom stats aggregate
#' @import dplyr
#' @import ggplot2
#'
#' @return a plot
#' @export
#'
#' @examples
#' \dontrun{
#' attributes_time(topsongs, "Top Songs", 1, averagesongs, "Average Songs", 4,
#' c("energy","speechiness"), FALSE, c(1960,2015), c("Top Songs","Average Songs"))
#' }
attributes_time <- function(df1, df1_title, df1_year_col, df2, df2_title, df2_year_col, attributes, boxplot, timerange, title_vector) {
  # in case column names not called "year"
  colnames(df1)[df1_year_col] <- "year"
  colnames(df2)[df2_year_col] <- "year"
  if(boxplot == FALSE) {
    # get mean for each attribute
    df1_avg <- aggregate(df1[,attributes], df1[,df1_year_col], mean)
    df2_avg <- aggregate(df2[,attributes], df2[,df2_year_col], mean)
    # rename first column (Group1 by default)
    colnames(df1_avg)[1] <- "year"
    colnames(df2_avg)[1] <- "year"
    # reshape function for plot:
    # df melt reshapes data frame with 3 columns: year, variable and value (value=avg here)
    df1_melt <- melt(as.data.frame(df1_avg), id = "year")
    df2_melt <- melt(as.data.frame(df2_avg),id = "year")
    # add col before binding
    df1_melt$type <- df1_title
    df2_melt$type <- df2_title
    df_avg <- rbind(df1_melt,df2_melt)
    # year as numeric for continuous plot
    df_avg$year <- as.numeric(as.character(df_avg$year))
    #return (df_avg)
    ggplot(df_avg %>% filter(type %in% title_vector), aes(x=year, y=value, color=variable, linetype = type)) + ylim(0,1)  + geom_line(size=1) + xlim(timerange)

  }
  else {
    # filter over wanted time
    df1_time <- as.data.frame(df1) %>% filter(year %in% timerange[1]:timerange[2])
    df2_time <- as.data.frame(df2) %>% filter(year %in% timerange[1]:timerange[2])
    # reshape
    df1_box_melt <- melt(df1_time,id.vars="year", measure.vars=attributes)
    df2_box_melt <-  melt(df2_time,id.vars="year", measure.vars=attributes)
    # add col before binding
    df1_box_melt$type <- df1_title
    df2_box_melt$type <- df2_title
    df_boxplot <- rbind(df1_box_melt,df2_box_melt)
    #return (df_boxplot)
    ggplot(df_boxplot %>% filter(type %in% title_vector)) + geom_boxplot(aes(x=year, y=value, fill=variable)) + theme(axis.text.x = element_text(angle=90)) + ylim(0,1)  + facet_grid(. ~ type)
  }
}
