#' Clean sales data
#'
#' @param df dataframe
#' @return cleaned dataframe
#' @export
clean_sales_ts <- function(df) {

  df %>%
    dplyr::distinct() %>%
    dplyr::arrange(date) %>%
    tidyr::fill(sales, .direction = "downup")
}
