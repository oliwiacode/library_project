#' Wykres trendu sprzedazy
#'
#' Agreguje sprzedaz do sumy dziennej (opcjonalnie w podziale na wybrana
#' zmienna metadanych), dzieki czemu linia jest czytelna takze dla panelu.
#'
#' @param df ramka danych ze sprzedaza.
#' @param group opcjonalna nazwa kolumny do podzialu (np. "type", "family").
#'   Jesli podana, kazda grupa to osobna kolorowa linia.
#' @param smooth czy dodac wygladzona linie trendu (geom_smooth). Domyslnie TRUE.
#' @param title tytul wykresu.
#' @return obiekt ggplot.
#' @importFrom dplyr group_by summarise across all_of
#' @importFrom ggplot2 ggplot aes geom_line geom_smooth theme_minimal labs
#' @importFrom rlang .data
#' @export
plot_sales_trends <- function(df, group = NULL, smooth = TRUE,
                              title = "Trend sprzedazy") {

  group_cols <- if (is.null(group)) "date" else c("date", group)

  agg <- df %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(group_cols))) %>%
    dplyr::summarise(sales = sum(sales, na.rm = TRUE), .groups = "drop")

  if (is.null(group)) {
    p <- ggplot2::ggplot(agg, ggplot2::aes(x = date, y = sales))
  } else {
    p <- ggplot2::ggplot(
      agg,
      ggplot2::aes(x = date, y = sales, colour = .data[[group]])
    )
  }

  p <- p + ggplot2::geom_line(alpha = 0.7)
  if (smooth) p <- p + ggplot2::geom_smooth(se = FALSE)

  p +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = title, x = "Data", y = "Sprzedaz", colour = group)
}
