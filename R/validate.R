#' Sprawdz jakosc danych szeregu czasowego sprzedazy
#'
#' Kontrola dostosowana do danych panelowych (wiele sklepow i kategorii na te
#' sama date). Sprawdza braki, duplikaty klucza (date, store_nbr, family),
#' poprawnosc dat, zakres wartosci oraz spojnosc czestotliwosci.
#'
#' Uwaga dotyczaca luk: \code{has_date_gaps} sprawdza, czy w kalendarzu calego
#' zbioru wystepuja dni bez ani jednego rekordu (luka globalna). Nie wykrywa
#' dziur w pojedynczym szeregu sklep-kategoria - do oceny kompletnosci panelu
#' sluzy osobny wskaznik \code{panel_completeness}.
#'
#' @param df ramka danych ze sprzedaza.
#' @return lista z raportem jakosci; pole \code{ok} mowi, czy nie ma powaznych
#'   problemow. Zawiera tez \code{n_series} (liczba szeregow sklep-kategoria)
#'   oraz \code{panel_completeness} (udzial faktycznych obserwacji w stosunku do
#'   pelnego panelu: n_series x liczba dni w zakresie).
#' @export
validate_sales_ts <- function(df) {
  # 1. braki: ile NA w kluczowych kolumnach
  missing_dates <- sum(is.na(df$date))
  missing_sales <- sum(is.na(df$sales))
  # 2. duplikaty KLUCZA, a nie calych wierszy (kazdy wiersz ma unikalne id)
  #    paste() zamiast interaction() - znacznie szybsze i lzejsze na ~3 mln wierszy
  key <- paste(df$date, df$store_nbr, df$family, sep = "_")
  duplicate_keys <- sum(duplicated(key))
  # 3. zakres wartosci: sprzedaz nie powinna byc ujemna
  negative_sales <- sum(df$sales < 0, na.rm = TRUE)
  # 4. spojnosc czestotliwosci: patrzymy na UNIKALNE daty i luki miedzy nimi
  unique_dates <- sort(unique(df$date[!is.na(df$date)]))
  if (length(unique_dates) == 0) {
    # skrajny przypadek: brak poprawnych dat
    return(list(
      ok = FALSE,
      n_rows = nrow(df),
      missing_dates = missing_dates,
      missing_sales = missing_sales,
      duplicate_keys = duplicate_keys,
      negative_sales = negative_sales,
      date_min = NA,
      date_max = NA,
      observed_days = 0L,
      expected_days = 0L,
      has_date_gaps = NA,
      n_series = NA_integer_,
      panel_completeness = NA_real_
    ))
  }
  gaps <- as.integer(diff(unique_dates))           # w dniach
  has_gaps <- any(gaps > 1)
  expected_days <- as.integer(diff(range(unique_dates))) + 1
  observed_days <- length(unique_dates)
  # 5. kompletnosc panelu: ile faktycznych obserwacji vs pelny panel
  #    pelny panel = liczba szeregow (sklep-kategoria) x liczba dni w zakresie
  has_keys <- all(c("store_nbr", "family") %in% names(df))
  if (has_keys) {
    n_series <- nrow(unique(df[, c("store_nbr", "family")]))
    panel_completeness <- nrow(df) / (n_series * expected_days)
  } else {
    n_series <- NA_integer_
    panel_completeness <- NA_real_
  }
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
    has_date_gaps = has_gaps,
    n_series = n_series,
    panel_completeness = panel_completeness
  )
}
