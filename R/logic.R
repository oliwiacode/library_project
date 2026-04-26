#' Sales analysis pipeline
#'
#' @param df dataframe
#' @param store optional store id
#' @param family optional product category
#' @return list
#' @export
sales_ts_logic <- function(df, store = NULL, family = NULL) {

  if (!is.null(store)) {
    df <- df %>% dplyr::filter(store_nbr == store)
  }

  if (!is.null(family)) {
    df <- df %>% dplyr::filter(family == family)
  }

  cleaned <- clean_sales_ts(df)

  list(
    metrics = compute_sales_metrics(cleaned),
    plot = plot_sales_trends(cleaned)
  )
}
