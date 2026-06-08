#' Wczytaj dane sprzedazowe (opcjonalnie wzbogacone o sklepy i swieta)
#'
#' Wczytuje plik sprzedazy (train.csv) i, jesli podano sciezki, dolacza
#' metadane sklepow (miasto/stan/typ/klaster) oraz flage swieta. Dzieki
#' temu pozniejsze funkcje moga grupowac po metadanych (miasto, stan, typ).
#'
#' @param sales_path sciezka do pliku CSV ze sprzedaza (kolumny:
#'   id, date, store_nbr, family, sales, onpromotion).
#' @param stores_path opcjonalna sciezka do stores.csv. Jesli podana,
#'   dolaczane sa kolumny city, state, type, cluster.
#' @param holidays_path opcjonalna sciezka do holidays_events.csv. Jesli
#'   podana, dodawana jest kolumna logiczna \code{is_holiday}.
#' @param n_max maksymalna liczba wierszy do wczytania (domyslnie wszystkie).
#'   Przydatne do szybkich testow na probce duzego pliku.
#' @return tibble z danymi sprzedazowymi.
#' @importFrom readr read_csv cols col_double col_character col_integer
#' @importFrom dplyr mutate left_join
#' @importFrom lubridate ymd
#' @export
load_sales_data <- function(sales_path,
                            stores_path = NULL,
                            holidays_path = NULL,
                            n_max = Inf) {
  # jawne typy kolumn = mniej niespodzianek niz zgadywanie przez read_csv
  data <- readr::read_csv(
    sales_path,
    n_max = n_max,
    col_types = readr::cols(
      id          = readr::col_double(),
      date        = readr::col_character(),
      store_nbr   = readr::col_integer(),
      family      = readr::col_character(),
      sales       = readr::col_double(),
      onpromotion = readr::col_double()
    )
  )
  data <- dplyr::mutate(data, date = lubridate::ymd(date))
  # opcjonalne dolaczenie metadanych sklepow
  if (!is.null(stores_path)) {
    stores <- readr::read_csv(stores_path, col_types = readr::cols())
    data <- dplyr::left_join(data, stores, by = "store_nbr")
  }
  # opcjonalna flaga swieta (wykorzystuje holidays_events.csv)
  if (!is.null(holidays_path)) {
    holidays <- readr::read_csv(holidays_path, col_types = readr::cols())
    data <- add_holiday_flag(data, holidays)
  }
  data
}

# Pomocnicza, wewnetrzna: dodaje kolumne is_holiday.
# Uproszczenie biznesowe: bierzemy swieta krajowe (National), ktore nie zostaly
# "przeniesione" (transferred == FALSE). Swieta lokalne/regionalne pomijamy,
# zeby nie komplikowac (wymagaloby dopasowania po miescie/stanie).
#' @importFrom dplyr filter distinct mutate
#' @importFrom lubridate ymd
#' @noRd
add_holiday_flag <- function(data, holidays) {
  # transferred moze byc wczytane jako logical (TRUE/FALSE) albo tekst ("True"/"False")
  # - normalizujemy do logical, zeby nie odfiltrowac przypadkiem wszystkich swiat
  holidays <- dplyr::mutate(holidays, transferred = as.logical(transferred))
  national <- holidays %>%
    dplyr::filter(locale == "National", !transferred) %>%
    dplyr::distinct(date)
  national_dates <- lubridate::ymd(national$date)
  data %>% dplyr::mutate(is_holiday = date %in% national_dates)
}
