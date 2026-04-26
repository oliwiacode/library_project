#' Plot sales trends
#'
#' @param df dataframe
#' @return ggplot
#' @export
plot_sales_trends <- function(df) {

  ggplot2::ggplot(df, ggplot2::aes(x = date, y = sales)) +
    ggplot2::geom_line() +
    ggplot2::geom_smooth(se = FALSE) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Sales Trend",
      x = "Date",
      y = "Sales"
    )
}
