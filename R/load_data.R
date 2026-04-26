#' Load sales data
#' @importFrom readr read_csv
#' @importFrom dplyr mutate
#' @importFrom lubridate ymd
#' @export
load_sales_data <- function(path) {

  readr::read_csv(path) %>%
    dplyr::mutate(date = lubridate::ymd(date))
}
