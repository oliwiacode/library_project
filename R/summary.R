#' Create management summary
#'
#' @param df dataframe
#' @return list
#' @export
create_management_summary <- function(df) {

  best_store <- df %>%
    dplyr::group_by(store_nbr) %>%
    dplyr::summarise(total = sum(sales, na.rm = TRUE)) %>%
    dplyr::slice_max(total, n = 1)

  worst_store <- df %>%
    dplyr::group_by(store_nbr) %>%
    dplyr::summarise(total = sum(sales, na.rm = TRUE)) %>%
    dplyr::slice_min(total, n = 1)

  growth <- df %>%
    dplyr::group_by(family, date) %>%
    dplyr::summarise(sales = sum(sales), .groups = "drop") %>%
    dplyr::group_by(family) %>%
    dplyr::mutate(growth = (sales / dplyr::lag(sales)) - 1) %>%
    dplyr::summarise(avg_growth = mean(growth, na.rm = TRUE)) %>%
    dplyr::slice_max(avg_growth, n = 1)

  list(
    best_store = best_store,
    worst_store = worst_store,
    fastest_growth_category = growth
  )
}
