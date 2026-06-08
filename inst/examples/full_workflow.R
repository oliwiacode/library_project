# =====================================================================
#  salesToolkit - pelny workflow analityczny
# ---------------------------------------------------------------------
#  Skrypt przedstawia kompletny proces analizy danych sprzedazowych:
#  od wczytania surowych danych, przez kontrole jakosci i przygotowanie,
#  po metryki biznesowe, wizualizacje, podsumowanie menedzerskie,
#  analize porownawcza segmentow oraz prognoze.
#
#  Uruchomienie:
#    1. Zainstaluj pakiet:  devtools::install()
#       (lub podczas pracy nad pakietem odkomentuj load_all ponizej)
#    2. Wskaz wlasne sciezki do plikow CSV (sekcja "Dane wejsciowe").
#    3. Uruchom skrypt w calosci lub krok po kroku.
# =====================================================================

# devtools::load_all(".")   # alternatywa dla install() podczas developmentu
library(salesToolkit)

# --- Dane wejsciowe (dostosuj sciezki u siebie) ----------------------
sales_path    <- "train.csv"
stores_path   <- "stores.csv"
holidays_path <- "holidays_events.csv"

# Wielkosc probki. Pelny plik ma ~3 mln wierszy; 1 mln daje ok. 1,5 roku
# historii - wystarczajaco, by prognoza uchwycila sezonowosc.
sample_size <- 1000000


# =====================================================================
#  1. Wczytanie i kontrola jakosci danych
# =====================================================================
# Laczymy sprzedaz z metadanymi sklepow i flaga swiat, a nastepnie
# sprawdzamy wiarygodnosc danych (braki, duplikaty, luki, kompletnosc).

raw <- load_sales_data(sales_path, stores_path, holidays_path,
                       n_max = sample_size)

quality <- validate_sales_ts(raw)
cat("\n--- Kontrola jakosci danych ---\n")
cat("Liczba rekordow:      ", quality$n_rows, "\n")
cat("Zakres dat:           ", as.character(quality$date_min), "-",
    as.character(quality$date_max), "\n")
cat("Braki (daty/sprzedaz):", quality$missing_dates, "/", quality$missing_sales, "\n")
cat("Duplikaty klucza:     ", quality$duplicate_keys, "\n")
cat("Kompletnosc panelu:   ", round(quality$panel_completeness * 100, 1), "%\n")


# =====================================================================
#  2. Przygotowanie danych
# =====================================================================
# Czyszczenie: braki w sprzedazy traktujemy jako 0 (zamkniety sklep),
# usuwamy duplikaty klucza, sortujemy. Bez agregacji - zachowujemy
# rozdzielczosc dzienna.

clean <- clean_sales_ts(
  raw,
  fill_missing = "zero",
  aggregate    = "none"
)


# =====================================================================
#  3. Metryki i wskazniki biznesowe
# =====================================================================
# Sprzedaz calkowita, srednia, zmiennosc, udzial promocji, rytm szczytow.

metrics <- compute_sales_metrics(clean, ma_window = 7)
cat("\n--- Kluczowe metryki ---\n")
print(metrics$summary)


# =====================================================================
#  4. Wizualizacja trendow
# =====================================================================
# Trend ogolny oraz w podziale na typ sklepu.

print(plot_sales_trends(clean, title = "Sprzedaz dzienna (calosc probki)"))

if ("type" %in% names(clean)) {
  print(plot_sales_trends(clean, group = "type",
                          title = "Sprzedaz wedlug typu sklepu"))
}


# =====================================================================
#  5. Podsumowanie menedzerskie
# =====================================================================
# Najlepszy/najslabszy sklep, dynamika kategorii, biezacy poziom sprzedazy.

mgmt <- create_management_summary(clean, recent_days = 30)
cat("\n--- Podsumowanie dla zarzadu ---\n")
cat("Najlepszy sklep (nr):", mgmt$best_store$store_nbr,
    "- sprzedaz:", round(mgmt$best_store$total), "\n")
cat("Najslabszy sklep (nr):", mgmt$worst_store$store_nbr,
    "- sprzedaz:", round(mgmt$worst_store$total), "\n")
cat("Najszybciej rosnaca kategoria:", mgmt$fastest_growth_category$family,
    "(", round(mgmt$fastest_growth_category$pct_change * 100, 1), "%)\n")
cat("Najwiekszy spadek:", mgmt$biggest_drop_category$family,
    "(", round(mgmt$biggest_drop_category$pct_change * 100, 1), "%)\n")
cat("Srednia sprzedaz dzienna (ostatnie 30 dni):",
    round(mgmt$last_period_avg_sales), "\n")


# =====================================================================
#  6. Analiza porownawcza segmentow
# =====================================================================
# Funkcja wyzszego rzedu sales_ts_logic() stosuje DOWOLNA funkcje
# analityczna do kazdego segmentu osobno - tu wg typu sklepu i wg stanu.

# (a) policz metryki dla kazdego typu sklepu naraz
metrics_by_type <- sales_ts_logic(clean, by = "type",
                                  fun = compute_sales_metrics)
cat("\n--- Dostepne segmenty (typ sklepu):",
    paste(names(metrics_by_type), collapse = ", "), "---\n")
# metryki pierwszego dostepnego typu (np. "A"):
print(metrics_by_type[[1]]$summary)

# (b) ta sama funkcja wyzszego rzedu, ale tym razem rysuje wykresy
plots_by_state <- sales_ts_logic(clean, by = "state",
                                 fun = plot_sales_trends)
print(plots_by_state[[1]])   # wykres dla pierwszego stanu


# =====================================================================
#  7. Prognozowanie
# =====================================================================
# Dwie niezalezne metody (ARIMA + Prophet) dla sumy sprzedazy calej
# sieci. create_prognosis() sam agreguje panel do jednego szeregu
# dziennego, wiec mozna podac dane panelowe bezposrednio.

prog <- create_prognosis(clean, h = 30)
cat("\n--- Prognoza 30-dniowa (pierwsze dni) ---\n")
print(head(prog$comparison))

cat("\n=== Workflow zakonczony ===\n")
