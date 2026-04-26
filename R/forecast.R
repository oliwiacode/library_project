#' Create sales forecast
#'
#' @param df dataframe
#' @return list
#' @export
create_prognosis <- function(df) {

  ts_data <- stats::ts(df$sales, frequency = 7)

  model_arima <- forecast::auto.arima(ts_data)
  forecast_arima <- forecast::forecast(model_arima, h = 30)

  prophet_df <- df %>%
    dplyr::select(ds = date, y = sales)

  model_prophet <- prophet::prophet(prophet_df)
  future <- prophet::make_future_dataframe(model_prophet, periods = 30)
  forecast_prophet <- predict(model_prophet, future)

  list(
    arima = forecast_arima,
    prophet = forecast_prophet
  )
}
