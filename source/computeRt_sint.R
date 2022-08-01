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
outputFolder <- "output//Rt_sint" 

# Giorni che si considerano NON consolidati 
int_consolidamento <- 14 # giorni che si considerano NON consolidati 

# Selezionare T per soltanto ultimo giorno, F per tutti i giorni
ultimo <- T

# Lettura dati ----
# I dati sui casi sintomatici per data inizio sintomi sono pubblicati dall'Istituto Superiore Sanita'
# https://www.epicentro.iss.it/coronavirus/open-data/covid_19-iss.xlsx
# File input archiviato da OnData https://ondata.it/
# file <- "https://raw.githubusercontent.com/ondata/covid19italia/master/webservices/iss_epicentro_dati/processing/casi_inizio_sintomi_sint.csv"
# oppure
# File input archiviato da Andrea Mignone https://twitter.com/i_m_andrea
file <- "https://raw.githubusercontent.com/floatingpurr/covid-19_sorveglianza_integrata_italia/main/data/latest/casi_inizio_sintomi_sint.csv"

data <- read.csv(file)
data$CASI_SINT <- suppressWarnings(as.numeric(data$CASI_SINT)) #elimina i "<5"
data[is.na(data)] <- 0
data$iss_date <- as.Date(data$iss_date, format = "%d/%m/%Y")
data$DATA_INIZIO_SINTOMI <- as.Date(data$DATA_INIZIO_SINTOMI, format = "%d/%m/%Y")
data <- na.omit(data) #Elimina i casi senza data inizio sintomi

storico_date <- unique(data$iss_date)

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
  curva.epidemica <- data[data$iss_date == storico_date[i], c(1,3)]
  colnames(curva.epidemica) <- c("Date", "I")
  
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
  R.medio <- stima$R$`Mean(R)` ## valore medio
  R.lowerCI <-
    stima$R$`Quantile.0.025(R)` ## estremo inferiore dell'intervallo di confidenza 
  R.upperCI <-
    stima$R$`Quantile.0.975(R)` ## estremo superiore dell'intervallo di confidenza
  
  ################################################################################
  
  # Nota: si tratta di intervalli di credibilita' e non di confidenza
  
  # Aggiunta note sul consolidamento
  Consolidato <- rep("Si", length(R.medio))
  Consolidato[length(Consolidato) - ((int_consolidamento-1):0)] <- "Sottostima"
  Consolidato[length(Consolidato) - ((ceiling(int_consolidamento/2)-1):0)] <- "Forte sottostima"
  
  # Salva risultati
  output <- data.frame(Data = curva.epidemica$Date[8:nrow(curva.epidemica)], R.lowerCI, R.medio, R.upperCI, Consolidato)
  fileOut1 <- here::here(outputFolder, paste0("Rt_sint_Ita_updated_", storico_date[i], ".csv"))
  write.csv(output, fileOut1, row.names = F)
  
  # Salva risultati piu' recenti in file a parte
  if(i == length(storico_date)){
    write.csv(output, here::here(outputFolder, "Rt_sint_Ita_updated_latest.csv"), row.names = F)
  }

}

Sys.setlocale("LC_TIME", "Italian") #per avere date in italiano

outputCons <- head(output, -int_consolidamento)

png(filename = here::here(outputFolder, "Rt_sint_Ita_updated_latest.png"), width = 465, height = 225, units='mm', res = 300)

  ggplot(outputCons, aes(x = Data, y = R.medio)) +
  geom_smooth(aes(ymin = R.lowerCI, ymax = R.upperCI), stat = "identity") +
  geom_hline(yintercept = 1) +
  labs(title = paste0("Rt_sintomi Italia fino al ", tail(outputCons$Data,1), 
                      " aggiornato al ", tail(storico_date,1), " con 95%CrI"), 
       x = "Data", y = "Rt_sint",
       subtitle = paste0("ATTENZIONE: dati ultimi ", int_consolidamento, " giorni esclusi in quanto non consolidati"),
       caption = paste0("Rt ottenuto con EpiEstim (tw=7gg, shape=", shape.stimato, " rate=", rate.stimato, ") da dati Istituto Superiore Sanità")) +
  ylim(0, NA) +
  geom_point(data = tail(outputCons,1), aes(x = Data, y = R.medio), size =3) +
  geom_text(data = tail(outputCons,1), aes(label = paste0(round(R.medio,2), " [", round(R.lowerCI,2), "-", round(R.upperCI,2), "]")),
            hjust=1.1,vjust=-0) +
  theme_minimal(base_size = 16) +
  scale_x_date(date_breaks = "1 month", date_labels="%b-%Y" ) +
  theme(axis.text.x = element_text(angle = 45, hjust=1))

dev.off()
