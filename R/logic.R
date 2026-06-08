#' Zastosuj funkcje analityczna na podzbiorach wg metadanych i czasu
#'
#' Funkcja WYZSZEGO RZEDU: przyjmuje funkcje \code{fun} jako argument i stosuje
#' ja osobno do kazdego podzbioru danych wyznaczonego przez wybrana zmienna
#' metadanych (np. miasto, stan, typ sklepu, kategoria). Opcjonalnie ogranicza
#' dane do zadanego przedzialu czasu. Zwraca nazwana liste wynikow.
#'
#' Dzieki przekazywaniu funkcji jako argumentu mozna jednym wywolaniem policzyc
#' metryki (compute_sales_metrics) ALBO narysowac wykresy (plot_sales_trends)
#' dla wszystkich miast/typow/itd.
#'
#' @param df ramka danych ze sprzedaza (najlepiej z dolaczonymi metadanymi sklepow).
#' @param by nazwa kolumny metadanych, po ktorej dzielimy dane
#'   (np. "city", "state", "type", "store_nbr", "family").
#' @param fun funkcja stosowana do kazdego podzbioru. Domyslnie
#'   \code{compute_sales_metrics}. Mozna podac np. \code{plot_sales_trends}.
#' @param date_range opcjonalny wektor dwoch dat c(od, do) ograniczajacy okres.
#' @param ... dodatkowe argumenty przekazywane do \code{fun}.
#' @return nazwana lista: jeden element na kazda wartosc zmiennej \code{by}.
#' @importFrom dplyr filter
#' @importFrom purrr map set_names
#' @export
sales_ts_logic <- function(df,
                           by = "store_nbr",
                           fun = compute_sales_metrics,
                           date_range = NULL,
                           ...) {

  stopifnot(by %in% names(df))
  fun <- match.fun(fun)                       # akceptuj nazwe funkcji lub funkcje

  # ograniczenie czasu ("i czasie" z wymagan)
  if (!is.null(date_range)) {
    df <- dplyr::filter(df, date >= date_range[1], date <= date_range[2])
  }

  # podzial na podzbiory wg wybranej zmiennej metadanych
  groups <- split(df, df[[by]])

  # serce funkcji wyzszego rzedu: zastosuj PRZEKAZANA funkcje do kazdego podzbioru
  purrr::map(groups, function(subset_df) fun(subset_df, ...)) %>%
    purrr::set_names(names(groups))
}
