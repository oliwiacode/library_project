#' Podsumowanie biznesowe dla menedzera
#'
#' Liczy: najlepszy/najgorszy sklep (wg sprzedazy calkowitej), najszybciej
#' rosnaca i najmocniej spadajaca kategorie (ostatni okres vs poprzedni okres)
#' oraz srednia sprzedaz dzienna w ostatnim okresie.
#'
#' @param df ramka danych ze sprzedaza.
#' @param recent_days dlugosc "ostatniego okresu" w dniach (domyslnie 30).
#' @return lista z elementami podsumowania.
#' @importFrom dplyr group_by summarise slice_max slice_min filter mutate arrange desc left_join
#' @export
create_management_summary <- function(df, recent_days = 30) {
  # --- sklepy: suma sprzedazy ---
  by_store <- df %>%
    dplyr::group_by(store_nbr) %>%
    dplyr::summarise(total = sum(sales, na.rm = TRUE), .groups = "drop")
  best_store  <- dplyr::slice_max(by_store, total, n = 1, with_ties = FALSE)
  worst_store <- dplyr::slice_min(by_store, total, n = 1, with_ties = FALSE)
  # --- kategorie: porownanie dwoch ostatnich okresow (stabilniejsze niz dzienny lag) ---
  max_date <- max(df$date, na.rm = TRUE)
  recent_start <- max_date - (recent_days - 1)
  prev_start   <- max_date - (2 * recent_days - 1)
  cat_recent <- df %>%
    dplyr::filter(date >= recent_start) %>%
    dplyr::group_by(family) %>%
    dplyr::summarise(total = sum(sales, na.rm = TRUE), .groups = "drop")
  cat_prev <- df %>%
    dplyr::filter(date >= prev_start, date < recent_start) %>%
    dplyr::group_by(family) %>%
    dplyr::summarise(prev_total = sum(sales, na.rm = TRUE), .groups = "drop")
  cat_growth <- cat_recent %>%
    dplyr::left_join(cat_prev, by = "family") %>%
    dplyr::mutate(
      # zabezpieczenie: brak danych w poprzednim okresie (NA) lub zerowa baza (0)
      # daja bezsensowne pct_change (NA / Inf), wiec oznaczamy je jako NA
      pct_change = ifelse(
        is.na(prev_total) | prev_total == 0,
        NA_real_,
        (total - prev_total) / prev_total
      )
    ) %>%
    dplyr::arrange(dplyr::desc(pct_change))
  fastest_growth <- dplyr::slice_max(cat_growth, pct_change, n = 1, with_ties = FALSE)
  biggest_drop   <- dplyr::slice_min(cat_growth, pct_change, n = 1, with_ties = FALSE)
  # --- ostatni okres: srednia sprzedaz dzienna ---
  last_period_avg <- df %>%
    dplyr::filter(date >= recent_start) %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(daily = sum(sales, na.rm = TRUE), .groups = "drop")
  last_period_avg_sales <- mean(last_period_avg$daily, na.rm = TRUE)
  list(
    best_store = best_store,
    worst_store = worst_store,
    fastest_growth_category = fastest_growth,
    biggest_drop_category = biggest_drop,
    category_growth_table = cat_growth,
    last_period_avg_sales = last_period_avg_sales,
    recent_days = recent_days
  )
}
