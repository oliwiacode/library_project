# 📊 salesToolkit

**Sales Time Series Analysis Toolkit in R**

A professional R package for loading, cleaning, analyzing, visualizing, and forecasting retail sales time series data.

---

# 🚀 Project Overview

salesToolkit is an R package designed for internal analytics teams in retail companies.  
It transforms raw sales data into actionable business insights using time series analysis and forecasting methods.

The package supports:

- Data ingestion and validation  
- Data cleaning and preprocessing  
- Business KPI computation  
- Time series visualization  
- Forecasting using ARIMA and Prophet  
- Automated management summaries  

---

# 📦 Installation

```r
install.packages(\"devtools\")

devtools::install_github(\"oliwiacode/library_project\")

```

# ⚙️ Usage

## 📥 Load data

### Option 1 — file in project folder

```r
data <- load_sales_data("train.csv")
```

### Option 2 — full path

```r
data <- load_sales_data("C:/Users/Admin/Documents/salesToolkit/train.csv")
```

## 🔍 Data validation

```r
validated <- validate_sales_ts(data)
```

## 🧹 Data cleaning

Note: this step uses dplyr internally (already included in Imports)

```r
cleaned <- clean_sales_ts(data)
```

## 📊 Business metrics

```r
metrics <- compute_sales_metrics(cleaned)
metrics
```

## 📈 Visualization

```r
plot_sales_trends(cleaned)
```

## 📋 Management summary

```r
summary <- create_management_summary(cleaned)
summary
```

## 🔮 Forecasting

```r
forecast <- create_prognosis(cleaned)
forecast
```

## 🧠 Notes
- Forecasting may take longer to compute due to ARIMA and Prophet models
- Large datasets (3M+ rows) may require additional processing time
- All functions are designed for retail time series analysis workflows

## 🧪 Data Source

- Store Sales Time Series Forecasting (Kaggle)  
  https://www.kaggle.com/competitions/store-sales-time-series-forecasting  

- Dataset is not included due to size limitations.
