#' Validate sales time series
#'
#' @param df dataframe
#' @return list with quality report
#' @export
validate_sales_ts <- function(df) {

  date_diff <- diff(sort(df$date))

  list(
    missing_values = sum(is.na(df)),
    duplicates = sum(duplicated(df)),
    negative_sales = sum(df$sales < 0, na.rm = TRUE),
    inconsistent_dates = any(date_diff > 1)
  )
}
