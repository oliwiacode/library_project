<div align="center">

# 📊 salesToolkit

### Pakiet R do analizy szeregów czasowych sprzedaży

*Zamień surowe dane sprzedażowe w czyste, gotowe do użycia wnioski biznesowe — od kontroli jakości danych po prognozy ARIMA i Prophet.*

![R](https://img.shields.io/badge/R-%E2%89%A5%204.0-276DC3?logo=r&logoColor=white)
![Wersja](https://img.shields.io/badge/wersja-0.2.0-success)
![Licencja](https://img.shields.io/badge/licencja-MIT-blue)
![Status](https://img.shields.io/badge/status-aktywny-brightgreen)

</div>

---

## 🧭 O projekcie

**salesToolkit** to pakiet R stworzony dla wewnętrznego zespołu analitycznego
w firmie detalicznej. Bierze surowe dane sprzedażowe — dzienną sprzedaż w wielu
sklepach i kategoriach produktów — i prowadzi je przez pełny proces analityczny:

1. **Wczytanie** danych sprzedażowych (opcjonalnie wzbogaconych o metadane sklepów i święta)
2. **Walidacja** jakości danych (braki, duplikaty kluczy, luki w datach, zakres wartości)
3. **Czyszczenie** i przekształcanie (uzupełnianie braków, usuwanie duplikatów, agregacja czasowa)
4. **Metryki** kluczowych wskaźników biznesowych (sumy, zmienność, średnie kroczące, udział promocji)
5. **Wizualizacja** trendów w sklepach, regionach i kategoriach
6. **Podsumowanie** wyników dla menedżera
7. **Prognoza** przyszłej sprzedaży dwiema niezależnymi metodami (ARIMA + Prophet)

Pakiet jest podzielony na trzy poziomy trudności, dzięki czemu można go czytać
i używać stopniowo.

---

## 📦 Instalacja

```r
# install.packages("devtools")
devtools::install_github("oliwiacode/library_project")
```

Praca nad pakietem lokalnie:

```r
devtools::load_all(".")
```

> **Zależności** instalują się automatycznie: `dplyr`, `tidyr`, `readr`,
> `lubridate`, `ggplot2`, `zoo`, `purrr`, `rlang`, `forecast`, `prophet`.

---

## 🧩 Funkcje

### 🟢 Poziom 1 — Podstawy

| Funkcja | Co robi |
|---|---|
| `load_sales_data(sales_path, stores_path, holidays_path, n_max)` | Wczytuje CSV ze sprzedażą, opcjonalnie dołącza metadane sklepów i dodaje flagę święta. |
| `validate_sales_ts(df)` | Raport jakości: braki, duplikaty klucza `(data, sklep, kategoria)`, ujemna sprzedaż, luki w datach. |
| `clean_sales_ts(df, fill_missing, dedupe, sort, aggregate, group_keys)` | Czyści dane **w obrębie każdego szeregu sklep × kategoria**: uzupełnia braki, usuwa duplikaty, sortuje, agreguje tygodniowo/miesięcznie. |
| `compute_sales_metrics(df, ma_window)` | Metryki biznesowe: suma, średnia, zmienność (CV), średnia krocząca, udział promocji, średnia odległość między szczytami sprzedaży. |

### 🟡 Poziom 2 — Raportowanie

| Funkcja | Co robi |
|---|---|
| `plot_sales_trends(df, group, smooth, title)` | Czytelna linia trendu dziennego, opcjonalnie z podziałem po kolumnie metadanych (np. `type` sklepu). |
| `create_management_summary(df, recent_days)` | Najlepszy/najgorszy sklep, najszybciej rosnąca i najmocniej spadająca kategoria, średnia sprzedaż ostatniego okresu. |
| 📄 `inst/report/sales_report.Rmd` | Gotowy do wyrenderowania raport o trendach sprzedaży **i skuteczności promocji**. |

### 🔴 Poziom 3 — Zaawansowane

| Funkcja | Co robi |
|---|---|
| `sales_ts_logic(df, by, fun, date_range, ...)` | **Funkcja wyższego rzędu**: stosuje dowolną funkcję (np. metryki lub wykresy) do podzbiorów wyznaczonych przez metadane (miasto / stan / typ) i czas. |
| `create_prognosis(df, h, freq)` | Prognoza 30-dniowa metodami **ARIMA + Prophet**, zwracana wraz z tabelą porównawczą. |

---

## ⚙️ Użycie

### Szybki start

```r
library(salesToolkit)

# 1. Wczytanie (próbka 300 tys. wierszy z pliku liczącego 3 mln, z metadanymi)
raw <- load_sales_data(
  sales_path    = "train.csv",
  stores_path   = "stores.csv",
  holidays_path = "holidays_events.csv",
  n_max         = 3e5
)

# 2. Walidacja
validate_sales_ts(raw)

# 3. Czyszczenie
clean <- clean_sales_ts(raw, fill_missing = "zero")

# 4. Metryki
compute_sales_metrics(clean)$summary
```

### Wizualizacja i podsumowanie (poziom 2)

```r
# ogólny trend dzienny
plot_sales_trends(clean, title = "Sprzedaż dzienna")

# trend w podziale na typ sklepu
plot_sales_trends(clean, group = "type", title = "Sprzedaż wg typu sklepu")

# podsumowanie menedżerskie na jeden rzut oka
create_management_summary(clean, recent_days = 30)
```

### Porównanie i prognoza (poziom 3)

```r
# funkcja wyższego rzędu: metryki dla każdego typu sklepu naraz
sales_ts_logic(clean, by = "type", fun = compute_sales_metrics)

# ten sam mechanizm, ale rysuje wykresy
sales_ts_logic(clean, by = "state", fun = plot_sales_trends)

# prognoza 30-dniowa: ARIMA vs Prophet
prog <- create_prognosis(clean, h = 30)
head(prog$comparison)
```

Pełny przykład end-to-end znajdziesz w
[`inst/examples/full_workflow.R`](inst/examples/full_workflow.R).

---

## 📈 Raport

Gotowy do wyrenderowania raport analityczny obejmujący poziomy 2 i 3 (trendy,
skuteczność promocji, porównanie typów sklepów, prognoza ARIMA vs Prophet)
znajduje się w:

```
inst/report/sales_report.Rmd
```

Renderowanie:

```r
rmarkdown::render(
  "inst/report/sales_report.Rmd",
  params = list(n_max = 3e5)
)
```

---

## 🗂️ Źródło danych

[**Store Sales — Time Series Forecasting**](https://www.kaggle.com/competitions/store-sales-time-series-forecasting) (Kaggle)

| Plik | Opis |
|---|---|
| `train.csv` | Dzienna sprzedaż wg sklepu i kategorii produktu (~3 mln wierszy, 2013–2017). |
| `stores.csv` | Metadane sklepów: miasto, stan, typ, klaster. |
| `holidays_events.csv` | Święta i wydarzenia krajowe, regionalne i lokalne. |

> ⚠️ Pliki z danymi **nie są** dołączone do pakietu ze względu na rozmiar.
> Pobierz je z Kaggle i wskaż ich lokalizację w argumentach `*_path`.

---

## 📁 Struktura projektu

```
salesToolkit/
├── R/                     # funkcje pakietu
├── man/                   # dokumentacja (roxygen2)
├── inst/
│   ├── examples/          # full_workflow.R
│   └── report/            # sales_report.Rmd
├── DESCRIPTION
├── NAMESPACE
└── README.md
```

---

## 📜 Licencja

Udostępniono na [licencji MIT](LICENSE.md).

<div align="center">

*Projekt zaliczeniowy z Analityki Biznesowej — wczytywanie, czyszczenie, metryki, wizualizacja i prognozowanie sprzedaży w jednym pakiecie R.*

</div>
