## jak użyć naszego pakietu
## najpierw instaluję pakiet
library(salesToolkit)

## wczytuje dane
data <- load_sales_data("train.csv")

## i teraz albo plik train.csv wrzucamy manualnie od razu do folderu aktualnego projektu (w moim przypadku "test"), ale piszemy w console ścieżkę:

data <- load_sales_data("C:/Users/Admin/Documents/salesToolkit/train.csv")

## i teraz używamy po kolei naszych funkcji z pakietu

validated <- validate_sales_ts(data)

## żeby użyć clean_sales_ts musimy zainstalować dplyr

library(dplyr)
cleaned <- clean_sales_ts(data)

#tu pięknie nam tabelke podsumowującą robi essa

metrics <- compute_sales_metrics(cleaned)

#tu nam wysrywa wykresik, trochę długo pracuje ale proszę się nie denerwować - w końcu wysra
plot_sales_trends(cleaned)

summary <- create_management_summary(cleaned) # tu podsumowanie piękne

forecast <- create_prognosis(cleaned) #tu też dłużej się męczy ale da radę tylko trzeba dać mu szansę
