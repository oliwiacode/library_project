# =====================================================================
# salesToolkit - pelny workflow (poziomy 1-3)
# Uruchom z katalogu projektu. Wskaz wlasne sciezki do plikow CSV.
# =====================================================================

# devtools::load_all(".")   # podczas pracy nad pakietem
library(salesToolkit)

# --- sciezki do danych (dostosuj u siebie) ---
sales_path    <- "train.csv"
stores_path   <- "stores.csv"
holidays_path <- "holidays_events.csv"

# ---------------------------------------------------------------------
# POZIOM 1: wczytanie, walidacja, czyszczenie, metryki
# ---------------------------------------------------------------------

# Wczytujemy probke (np. 300 tys. wierszy) - caly plik ma 3 mln wierszy.
raw <- load_sales_data(sales_path, stores_path, holidays_path, n_max = 300000)

quality <- validate_sales_ts(raw)
print(quality)

clean <- clean_sales_ts(
  raw,
  fill_missing = "zero",
  aggregate    = "none"
)

metrics <- compute_sales_metrics(clean, ma_window = 7)
print(metrics$summary)

# ---------------------------------------------------------------------
# POZIOM 2: wizualizacja + podsumowanie dla menedzera
# ---------------------------------------------------------------------

print(plot_sales_trends(clean, title = "Sprzedaz dzienna (calosc probki)"))
print(plot_sales_trends(clean, group = "type", title = "Sprzedaz wg typu sklepu"))

mgmt <- create_management_summary(clean, recent_days = 30)
print(mgmt$best_store)
print(mgmt$worst_store)
print(mgmt$fastest_growth_category)
print(mgmt$biggest_drop_category)
cat("Srednia sprzedaz w ostatnim okresie:", mgmt$last_period_avg_sales, "\n")

# ---------------------------------------------------------------------
# POZIOM 3: funkcja wyzszego rzedu + prognoza + porownanie
# ---------------------------------------------------------------------

# sales_ts_logic stosuje przekazana funkcje do kazdego typu sklepu:
metrics_by_type <- sales_ts_logic(clean, by = "type", fun = compute_sales_metrics)
# np. metryki dla sklepow typu "A":
print(metrics_by_type[["A"]]$summary)

# ta sama funkcja wyzszego rzedu, ale tym razem rysuje wykresy:
plots_by_state <- sales_ts_logic(clean, by = "state", fun = plot_sales_trends)
# print(plots_by_state[[1]])

# Prognoza (ARIMA + Prophet) dla calosci probki:
prog <- create_prognosis(clean, h = 30)
print(head(prog$comparison))
