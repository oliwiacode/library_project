#' Load sales data
#' @importFrom readr read_csv
#' @importFrom dplyr mutate
#' @importFrom lubridate ymd
#' @export
load_sales_data <- function(path) {

  data <- readr::read_csv(path)

  data <- dplyr::mutate(
    data,
    date = lubridate::ymd(date)
  )

  return(data)
}
