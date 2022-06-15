# Per massima riproducibilita', questo codice e' basato sullo script calcoloRt_EpiEstim.R pubblicato dalla Fondazione Bruno Kessler
# scaricabile da https://www.epicentro.iss.it/coronavirus/open-data/calcolo_rt_italia.zip
# 
# Il pacchetto Epiestim e' sviluppato da Cori et al. 
# https://CRAN.R-project.org/package=EpiEstim
# https://cran.r-project.org/web/packages/EpiEstim/EpiEstim.pdf

library(EpiEstim)
library(here)
library(ggplot2)

set.seed(42)

# Parametri ----
# Cambiare con nome cartella desiderata
outputFolder <- "output//regioneLombardia" 

# Giorni che si considerano NON consolidati 
int_consolidamento <- 14 # giorni che si considerano NON consolidati 

# Selezionare T per soltanto ultimo giorno, F per tutti i giorni
ultimo <- T

# Lettura dati ----
# I dati sugli stati clinici Covid-19 inviati a ISS sono pubblicati da Regione Lombardia
# https://hub.dati.lombardia.it/Sanit-/Matrice-degli-stati-clinici-Covid-19-inviati-a-ISS/7jw9-ygfv
# File input archiviati da opencovid-mr

basePath <- "https://raw.githubusercontent.com/opencovid-mr/Lombardia-Stati_Clinici/main/data/"

storico_date <- seq(as.Date("2021-02-18"), as.Date("2021-11-18"), 7)
storico_date <- c(storico_date, as.Date("2021-11-30"), as.Date("2021-12-03")) #Reg Lombardia pare aver spostato la data degli aggiornamenti
if(Sys.Date() >= as.Date("2021-12-09")) {storico_date <- c(storico_date, seq(as.Date("2021-12-09"), Sys.Date(), 7))} #Reg Lombardia pare aver ripristinato la data degli aggiornamenti
storico_date <- storico_date[!storico_date==as.Date("2021-07-01")] #non aggiornato da Reg Lombardia in questa data
storico_date <- storico_date[!storico_date==as.Date("2022-06-08")] #non aggiornato da Reg Lombardia in questa data
storico_date = "2022-06-09"

# Verbatim da calcoloRt_EpiEstim.R #############################################

## parametri dell'intervallo seriale stimati da dati di contact tracing lombardi
shape.stimato <- 1.87
rate.stimato <- 0.28

## massimo numero di giorni dell'intervallo seriale
N <- 300

## definisco la distribuzione dell'intervallo seriale
intervallo.seriale <- dgamma(0:N, shape = shape.stimato, rate = rate.stimato)

## normalizzo la distribuzione dell'intervallo seriale in modo che la somma faccia 1
SI <- (intervallo.seriale / sum(intervallo.seriale))

################################################################################

if(ultimo){
  toDo <- length(storico_date)
}else{
  toDo <-1:length(storico_date)
}

# Stima Rt
for (i in toDo) {
  file <- paste0(basePath, storico_date[i], ".csv")
  
  data <- read.csv(file)
  data <- data[data$data_inizio_sintomi != "",]
  data$data_inizio_sintomi <- as.Date(data$data_inizio_sintomi)
  data <- data[order(data$data_inizio_sintomi),]
  data[is.na(data)] <- 0
  
  # Selezionare solo stati clinici sintomatici
  temp_incidence <- data[, c("solo_st_lieve_pau_severo", 
                             "st_lieve_pau_severo_grave_g",
                             "st_lieve_pau_severo_grave_d")]
  temp_incidence <- rowSums(temp_incidence)
  
  curva.epidemica <- data.frame(Date = data[,1], I = temp_incidence)
  
  
  # Verbatim da calcoloRt_EpiEstim.R #############################################
  
  ## calcolo la stima di R applicando la funzione estimate_R del pacchetto EpiEstim
  stima <-
    estimate_R(incid = curva.epidemica,
               method = "non_parametric_si",
               config = make_config(
                 list(
                   si_distr = SI,
                   n1 = 10000,
                   mcmc_control = make_mcmc_control(thin = 1, burnin = 1000000)
                 )
               ))
  
  ## il pacchetto avvisa che la stima di Rt viene fornita con una media mobile settimanale ("Default config will estimate R on weekly sliding windows"), eventualmente personalizzabile
  ## avvisa inoltre che la parte iniziale della curva non e' sufficiente alla stima corretta della variabilita' di Rt ("You're estimating R too early in the epidemic to get the desired posterior CV")
  
  ###################
  ### Attenzione! ###
  ###################
  
  ## La stima e' calcolata su tutta la curva epidemica specificata, ma il pacchetto non puo' tenere conto dei ritardi di inserimento nel dato
  ## Le stime di Rt varieranno man mano che vengono inseriti nuovi casi con data di inizio sintomi indietro nel tempo
  ## Per questo motivo ISS considera valide le stime fino a 14 giorni prima della data in cui viene effettuata la stima.
  ## Questo ritardo puo' cambiare nel tempo
  
  ## estraggo i risultati di interesse
  R.medio   <- stima$R$`Mean(R)` ## valore medio
  R.lowerCI <- stima$R$`Quantile.0.025(R)` ## estremo inferiore dell'intervallo di confidenza 
  R.upperCI <- stima$R$`Quantile.0.975(R)` ## estremo superiore dell'intervallo di confidenza
  
  ################################################################################
  
  # Nota: si tratta di intervalli di credibilita' e non di confidenza
  
  # Aggiunta note sul consolidamento
  Consolidato <- rep("Si", length(R.medio))
  Consolidato[length(Consolidato) - ((int_consolidamento-2):0)] <- "Sottostima"
  Consolidato[length(Consolidato) - ((ceiling(int_consolidamento/2)-1):0)] <- "Forte sottostima"
  
  # Salva risultati
  output   <- data.frame(Data = curva.epidemica$Date[8:nrow(curva.epidemica)], R.lowerCI, R.medio, R.upperCI, Consolidato)
  fileOut1 <- here::here(outputFolder, paste0("Rt_sint_regLombardia_updated_", storico_date[i]-1, ".csv"))
  write.csv(output, fileOut1, row.names = F)
  
  # Salva risultati piu' recenti in file a parte
  if(i == length(storico_date)){
    write.csv(output, here::here(outputFolder, "Rt_sint_regLombardia_updated_latest.csv"), row.names = F)
  }
  
}

Sys.setlocale("LC_TIME", "Italian") #per avere date in italiano

outputCons <- head(output, -(int_consolidamento-1))

png(filename = here::here(outputFolder, "Rt_sint_regLombardia_updated_latest.png"), width = 465, height = 225, units='mm', res = 300)

ggplot(outputCons, aes(x = Data, y = R.medio)) +
  geom_smooth(aes(ymin = R.lowerCI, ymax = R.upperCI), stat = "identity") +
  geom_hline(yintercept = 1) +
  labs(title = paste0("Rt_sintomi Regione Lombardia fino al ", tail(outputCons$Data,1), 
                      " aggiornato al ", tail(storico_date,1)-1, " con 95%CrI"), 
       x = "Data", y = "Rt_sint",
       subtitle = paste0("ATTENZIONE: dati ultimi ", int_consolidamento, " giorni esclusi in quanto non consolidati"),
       caption = paste0("Rt ottenuto con EpiEstim (tw=7gg, shape=", shape.stimato, " rate=", rate.stimato, ") da dati Regione Lombardia")) +
  ylim(0, NA) +
  geom_point(data = tail(outputCons,1), aes(x = Data, y = R.medio), size =3) +
  geom_text(data = tail(outputCons,1), aes(label = paste0(round(R.medio,2), " [", round(R.lowerCI,2), "-", round(R.upperCI,2), "]")),
            hjust=1.1,vjust=-0) +
  theme_minimal(base_size = 16) +
  scale_x_date(date_breaks = "1 month", date_labels="%b-%Y" ) +
  theme(axis.text.x = element_text(angle = 45, hjust=1))

dev.off()
