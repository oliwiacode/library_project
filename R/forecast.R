#' Prognoza sprzedazy: ARIMA + Prophet
#'
#' Najpierw agreguje dane do jednego regularnego szeregu dziennego (suma
#' sprzedazy na date, uzupelnienie brakujacych dni zerami), a nastepnie buduje
#' dwie prognozy: ARIMA (auto.arima) i Prophet. Zwraca tez wspolna tabele do
#' porownania obu metod.
#'
#' @param df ramka danych ze sprzedaza (date, sales).
#' @param h horyzont prognozy w dniach (domyslnie 30).
#' @param freq czestotliwosc sezonowa dla ARIMA (domyslnie 7 = tydzien).
#' @return lista: \code{arima} (forecast), \code{prophet} (predict),
#'   \code{history} (szereg historyczny) oraz \code{comparison}
#'   (tibble: date, arima, prophet dla okresu prognozy).
#' @importFrom dplyr group_by summarise arrange mutate select left_join filter
#' @importFrom tidyr complete
#' @importFrom forecast auto.arima forecast
#' @importFrom prophet prophet make_future_dataframe
#' @export
create_prognosis <- function(df, h = 30, freq = 7) {

  # 1. jeden regularny szereg dzienny (kluczowa poprawka wzgledem panelu)
  # 1. jeden regularny szereg dzienny
  history <- df %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(sales = sum(sales, na.rm = TRUE), .groups = "drop") %>%
    dplyr::arrange(date)

  # uzupelnienie brakujacych dni
  all_dates <- seq.Date(as.Date(min(history$date)),
                        as.Date(max(history$date)),
                        by = "day")
  history <- history %>%
    dplyr::right_join(data.frame(date = all_dates), by = "date") %>%
    dplyr::mutate(sales = ifelse(is.na(sales), 0, sales)) %>%
    dplyr::arrange(date)

  # 2. ARIMA
  ts_data <- stats::ts(history$sales, frequency = freq)
  model_arima <- forecast::auto.arima(ts_data)
  fc_arima <- forecast::forecast(model_arima, h = h)

  # 3. Prophet (wymaga kolumn ds, y)
  prophet_df <- history %>% dplyr::select(ds = date, y = sales)
  model_prophet <- prophet::prophet(prophet_df)
  future <- prophet::make_future_dataframe(model_prophet, periods = h)
  fc_prophet <- stats::predict(model_prophet, future)

  # 4. wspolna tabela porownawcza (tylko okres prognozy)
  future_dates <- seq(max(history$date) + 1, by = "day", length.out = h)
  comparison <- data.frame(
    date   = future_dates,
    arima  = as.numeric(fc_arima$mean),
    prophet = utils::tail(fc_prophet$yhat, h)
  )

  list(
    arima = fc_arima,
    prophet = fc_prophet,
    history = history,
    comparison = comparison
  )
}
