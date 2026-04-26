# salesTsPackage

A simple R package for sales time series analysis.

## Example workflow

```r
library(salesTsPackage)

data <- load_sales_data("train.csv")

validated <- validate_sales_ts(data)

cleaned <- clean_sales_ts(data)

metrics <- compute_sales_metrics(cleaned)

plot_sales_trends(cleaned)

summary <- create_management_summary(cleaned)

forecast <- create_prognosis(cleaned)
