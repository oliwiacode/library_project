#' Sprawdz jakosc danych szeregu czasowego sprzedazy
#'
#' Kontrola dostosowana do danych panelowych (wiele sklepow i kategorii na te
#' sama date). Sprawdza braki, duplikaty klucza (date, store_nbr, family),
#' poprawnosc dat, zakres wartosci oraz spojnosc czestotliwosci (luki w dniach).
#'
#' @param df ramka danych ze sprzedaza.
#' @return lista z raportem jakosci; pole \code{ok} mowi, czy nie ma powaznych
#'   problemow.
#' @importFrom dplyr summarise n_distinct
#' @export
validate_sales_ts <- function(df) {

  # 1. braki: ile NA w kluczowych kolumnach
  missing_dates <- sum(is.na(df$date))
  missing_sales <- sum(is.na(df$sales))

  # 2. duplikaty KLUCZA, a nie calych wierszy (kazdy wiersz ma unikalne id)
  key <- interaction(df$date, df$store_nbr, df$family, drop = TRUE)
  duplicate_keys <- sum(duplicated(key))

  # 3. zakres wartosci: sprzedaz nie powinna byc ujemna
  negative_sales <- sum(df$sales < 0, na.rm = TRUE)

  # 4. spojnosc czestotliwosci: patrzymy na UNIKALNE daty i luki miedzy nimi
  unique_dates <- sort(unique(df$date[!is.na(df$date)]))
  gaps <- as.integer(diff(unique_dates))           # w dniach
  has_gaps <- any(gaps > 1)
  expected_days <- as.integer(diff(range(unique_dates))) + 1
  observed_days <- length(unique_dates)

  ok <- missing_dates == 0 && duplicate_keys == 0 &&
    negative_sales == 0 && !has_gaps

  list(
    ok = ok,
    n_rows = nrow(df),
    missing_dates = missing_dates,
    missing_sales = missing_sales,
    duplicate_keys = duplicate_keys,
    negative_sales = negative_sales,
    date_min = min(unique_dates),
    date_max = max(unique_dates),
    observed_days = observed_days,
    expected_days = expected_days,
    has_date_gaps = has_gaps
  )
}
