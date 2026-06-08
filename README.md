<div align="center">

# 📊 salesToolkit

**Od surowych danych sprzedażowych do decyzji biznesowych — w jednym pakiecie R.**

salesToolkit to wewnętrzne narzędzie analityczne dla zespołów handlu detalicznego.
Wczytuje, porządkuje i bada dane sprzedażowe w czasie, liczy kluczowe wskaźniki,
buduje wizualizacje i prognozy - tak, żeby analityk mógł skupić się na wnioskach,
a nie na technikaliach.

---

## Dlaczego salesToolkit

Zespoły analityczne tracą większość czasu nie na analizie, lecz na przygotowaniu
danych. salesToolkit zamyka cały ten proces w spójnym zestawie funkcji:

- 🧹 **Czyste dane bez wysiłku** — walidacja jakości i czyszczenie (braki, duplikaty, luki w datach) w obrębie każdego sklepu i kategorii.
- 📐 **Wskaźniki gotowe do raportu** — sprzedaż, zmienność, średnie kroczące, udział promocji i rytm sezonowy liczone jedną komendą.
- 📈 **Wizualizacje pod prezentację** — czytelne trendy z podziałem na sklepy, regiony czy formaty.
- 🧭 **Podsumowanie dla zarządu** — najlepsze i najsłabsze sklepy, rosnące i kurczące się kategorie, kondycja ostatniego okresu.
- 🔮 **Prognozy w dwóch metodach** — ARIMA i Prophet obok siebie, z gotowym porównaniem.

---

## Instalacja

```r
# install.packages("devtools")
devtools::install_github("oliwiacode/library_project")
```

Praca nad pakietem lokalnie:

```r
devtools::load_all(".")
```

> Zależności instalują się automatycznie: `dplyr`, `tidyr`, `readr`, `lubridate`,
> `ggplot2`, `zoo`, `purrr`, `rlang`, `forecast`, `prophet`.

---

## ⚙️ Przykładowe użycie

```r
library(salesToolkit)

# 1-3. Wczytanie, walidacja, czyszczenie
sprzedaz <- load_sales_data("train.csv", "stores.csv", "holidays_events.csv", n_max = 3e5)
validate_sales_ts(sprzedaz)
dane <- clean_sales_ts(sprzedaz, fill_missing = "zero")

# 4. Metryki biznesowe
compute_sales_metrics(dane)$summary

# 5. Wizualizacja
plot_sales_trends(dane, group = "type", title = "Sprzedaż wg typu sklepu")

# 6. Podsumowanie dla menedżera
create_management_summary(dane, recent_days = 30)

# Poziom 3: analiza wg metadanych + prognoza
sales_ts_logic(dane, by = "type", fun = compute_sales_metrics)
create_prognosis(dane, h = 30)$comparison
```

Pełny scenariusz end-to-end:
[`inst/examples/full_workflow.R`](inst/examples/full_workflow.R).

---

## Funkcje

### Dane: wczytanie i jakość

| Funkcja | Zastosowanie |
|---|---|
| `load_sales_data(sales_path, stores_path, holidays_path, n_max)` | Wczytuje sprzedaż, opcjonalnie dołącza metadane sklepów i flagę świąt. |
| `validate_sales_ts(df)` | Raport jakości: braki, duplikaty klucza `(data, sklep, kategoria)`, ujemna sprzedaż, luki w datach. |
| `clean_sales_ts(df, fill_missing, dedupe, sort, aggregate, group_keys)` | Porządkuje dane w obrębie każdego szeregu sklep × kategoria: uzupełnia braki, usuwa duplikaty, sortuje, agreguje tygodniowo/miesięcznie. |

### Analiza i wskaźniki

| Funkcja | Zastosowanie |
|---|---|
| `compute_sales_metrics(df, ma_window)` | Sprzedaż całkowita i średnia, zmienność (CV), średnia krocząca, udział promocji, średnia odległość między szczytami. |
| `create_management_summary(df, recent_days)` | Najlepszy i najsłabszy sklep, najszybciej rosnąca i najmocniej spadająca kategoria, średnia sprzedaż ostatniego okresu. |

### Wizualizacja

| Funkcja | Zastosowanie |
|---|---|
| `plot_sales_trends(df, group, smooth, title)` | Czytelny trend dzienny, opcjonalnie z podziałem kolorem po metadanych (np. format sklepu, region). |

### Analiza zaawansowana

| Funkcja | Zastosowanie |
|---|---|
| `sales_ts_logic(df, by, fun, date_range, ...)` | Stosuje wybraną funkcję analityczną do podzbiorów danych wg metadanych (miasto / region / format) i przedziału czasu — np. metryki albo wykresy dla każdego segmentu naraz. |
| `create_prognosis(df, h, freq)` | Prognoza sprzedaży metodami ARIMA i Prophet, z tabelą porównawczą obu podejść. |

---

## Raport

Gotowy do wyrenderowania raport analityczny — trendy sprzedaży, skuteczność
promocji, porównanie formatów sklepów oraz prognoza ARIMA vs Prophet:

```r
rmarkdown::render(
  "inst/report/sales_report.Rmd",
  params = list(n_max = 3e5)
)
```

Plik źródłowy: `inst/report/sales_report.Rmd`.

---

## Źródło danych

Pakiet jest dostosowany do struktury danych
[**Store Sales — Time Series Forecasting**](https://www.kaggle.com/competitions/store-sales-time-series-forecasting) (Kaggle).

| Plik | Zawartość |
|---|---|
| `train.csv` | Dzienna sprzedaż wg sklepu i kategorii produktu. |
| `stores.csv` | Metadane sklepów: miasto, region, format, klaster. |
| `holidays_events.csv` | Święta i wydarzenia krajowe, regionalne i lokalne. |

> ⚠️ Pliki z danymi nie są dołączone do pakietu ze względu na rozmiar.
> Wskaż ich lokalizację w argumentach `*_path`.

---

<div align="center">

Udostępniono na [licencji MIT](LICENSE.md).

</div>
