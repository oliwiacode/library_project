#' Wyczysc i przygotuj dane sprzedazowe
#'
#' Obsluguje braki, duplikaty dat, sortowanie i (opcjonalnie) agregacje czasowa.
#' Wszystkie operacje sa wykonywane W RAMACH grupy (sklep + kategoria), zeby nie
#' mieszac szeregow roznych sklepow/kategorii.
#'
#' @param df ramka danych ze sprzedaza.
#' @param fill_missing sposob uzupelniania brakow w \code{sales}:
#'   "zero" (domyslnie - brak najczesciej oznacza zamkniety sklep),
#'   "interpolate" (interpolacja liniowa), "none" (zostaw NA).
#' @param dedupe czy usuwac duplikaty klucza (date, store_nbr, family). Domyslnie TRUE.
#' @param sort czy sortowac wg grupy i daty. Domyslnie TRUE.
#' @param aggregate agregacja czasowa: "none" (domyslnie), "weekly", "monthly".
#' @param group_keys kolumny definiujace pojedynczy szereg. Domyslnie
#'   c("store_nbr", "family").
#' @return wyczyszczona tibble.
#' @importFrom dplyr distinct arrange across all_of group_by ungroup summarise mutate
#' @importFrom zoo na.approx
#' @importFrom lubridate floor_date
#' @export
clean_sales_ts <- function(df,
                           fill_missing = c("zero", "interpolate", "none"),
                           dedupe = TRUE,
                           sort = TRUE,
                           aggregate = c("none", "weekly", "monthly"),
                           group_keys = c("store_nbr", "family")) {

  fill_missing <- match.arg(fill_missing)
  aggregate    <- match.arg(aggregate)

  # uzywamy tylko tych kluczy, ktore faktycznie sa w danych
  group_keys <- intersect(group_keys, names(df))

  # 1. duplikaty klucza (date + grupy) - zostawiamy pierwszy wpis
  if (dedupe) {
    df <- dplyr::distinct(df, dplyr::across(dplyr::all_of(c("date", group_keys))),
                          .keep_all = TRUE)
  }

  # 2. sortowanie wg grupy i daty
  if (sort) {
    df <- dplyr::arrange(df, dplyr::across(dplyr::all_of(c(group_keys, "date"))))
  }

  # 3. uzupelnianie brakow - zawsze w obrebie grupy
  if (fill_missing != "none" && length(group_keys) > 0) {
    df <- dplyr::group_by(df, dplyr::across(dplyr::all_of(group_keys)))
    if (fill_missing == "zero") {
      df <- dplyr::mutate(df, sales = ifelse(is.na(sales), 0, sales))
    } else if (fill_missing == "interpolate") {
      df <- dplyr::mutate(
        df,
        sales = zoo::na.approx(sales, na.rm = FALSE)
      )
    }
    df <- dplyr::ungroup(df)
  }

  # 4. agregacja czasowa (tygodniowa / miesieczna)
  if (aggregate != "none") {
    unit <- if (aggregate == "weekly") "week" else "month"
    df <- df %>%
      dplyr::mutate(date = lubridate::floor_date(date, unit)) %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(c("date", group_keys)))) %>%
      dplyr::summarise(
        sales = sum(sales, na.rm = TRUE),
        onpromotion = sum(onpromotion, na.rm = TRUE),
        .groups = "drop"
      )
  }

  df
}
