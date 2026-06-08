#' Oblicz biznesowe metryki sprzedazy
#'
#' Funkcja najpierw agreguje dane do jednego szeregu dziennego (suma sprzedazy
#' na date), dzieki czemu dziala poprawnie zarowno dla pojedynczego sklepu/
#' kategorii, jak i dla calego panelu. Zwraca metryki zbiorcze oraz szereg
#' dzienny ze srednia kroczaca (zeby srednia krocząca nie byla wyrzucana).
#'
#' @param df ramka danych ze sprzedaza (kolumny date, sales, onpromotion).
#' @param ma_window okno sredniej kroczacej w dniach (domyslnie 7).
#' @return lista: \code{summary} (tibble z metrykami) oraz \code{daily}
#'   (tibble: date, sales, moving_avg).
#' @importFrom dplyr group_by summarise mutate arrange
#' @importFrom zoo rollmean
#' @export
compute_sales_metrics <- function(df, ma_window = 7) {
  has_promo <- "onpromotion" %in% names(df)
  # 1. sprowadzenie do jednego szeregu dziennego
  if (has_promo) {
    daily <- df %>%
      dplyr::group_by(date) %>%
      dplyr::summarise(
        sales = sum(sales, na.rm = TRUE),
        onpromotion = sum(onpromotion, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      dplyr::arrange(date)
  } else {
    daily <- df %>%
      dplyr::group_by(date) %>%
      dplyr::summarise(
        sales = sum(sales, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      dplyr::arrange(date)
    daily$onpromotion <- NA_real_
  }
  # 2. srednia kroczaca - tym razem ZACHOWANA w wyniku
  #    zabezpieczenie: rollmean wymaga k <= liczby wierszy
  daily <- dplyr::mutate(
    daily,
    moving_avg = if (nrow(daily) >= ma_window) {
      zoo::rollmean(sales, k = ma_window, fill = NA, align = "right")
    } else {
      NA_real_
    }
  )
  # 3. metryki zbiorcze
  total_sales        <- sum(daily$sales, na.rm = TRUE)
  avg_sales          <- mean(daily$sales, na.rm = TRUE)
  sd_sales           <- stats::sd(daily$sales, na.rm = TRUE)
  avg_between_peaks  <- days_between_peaks(daily)
  summary <- data.frame(
    total_sales            = total_sales,
    avg_sales              = avg_sales,
    median_sales           = as.numeric(stats::median(daily$sales, na.rm = TRUE)),
    sd_sales               = sd_sales,
    coeff_var              = sd_sales / avg_sales,
    promo_days_share       = mean(daily$onpromotion > 0, na.rm = TRUE),
    avg_items_on_promo     = mean(daily$onpromotion, na.rm = TRUE),
    avg_days_between_peaks = avg_between_peaks
  )
  list(summary = summary, daily = daily)
}

# Pomocnicza: srednia odleglosc (w dniach) miedzy lokalnymi szczytami sprzedazy.
# Szczyt = dzien, w ktorym sprzedaz jest wyzsza niz dzien poprzedni i nastepny.
# To prosty wskaznik rytmu/sezonowosci sprzedazy.
#' @noRd
days_between_peaks <- function(daily) {
  s <- daily$sales
  n <- length(s)
  if (n < 3) return(NA_real_)
  is_peak <- c(FALSE, s[2:(n - 1)] > s[1:(n - 2)] & s[2:(n - 1)] > s[3:n], FALSE)
  peak_dates <- daily$date[is_peak]
  if (length(peak_dates) < 2) return(NA_real_)
  mean(as.integer(diff(peak_dates)))
}
