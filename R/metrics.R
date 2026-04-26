#' Compute sales metrics
#'
#' @param df dataframe
#' @return tibble
#' @export
compute_sales_metrics <- function(df) {

  df <- df %>%
    dplyr::arrange(date)

  df <- df %>%
    dplyr::mutate(
      moving_avg = zoo::rollmean(sales, k = 7, fill = NA, align = "right")
    )

  summary <- df %>%
    dplyr::summarise(
      total_sales = sum(sales, na.rm = TRUE),
      avg_sales = mean(sales, na.rm = TRUE),
      sd_sales = sd(sales, na.rm = TRUE),
      promo_share = mean(onpromotion, na.rm = TRUE)
    )

  summary %>%
    dplyr::mutate(
      coeff_var = sd_sales / avg_sales
    )
}
