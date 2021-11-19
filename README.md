# stima_rt

Codice R per stimare indice Rt_sintomi e Rt_ricoveri dell'Italia, Rt_sintomi di Regione Lombardia e Rt_ricoveri di tutte le Regioni/PPAA

[![GitHub commit](https://img.shields.io/github/last-commit/opencovid-mr/stima_rt)](https://github.com/opencovid-mr/stima_rt/commits/master)



**Le stime dei giorni più recenti (14 per Rt_sintomi, 7 giorni per Rt_ricoveri) sono sottostime in quanto derivano da dati non consolidati**

**Le stime sono calcolate senza distinzione tra casi autoctoni e casi importati in quanto tale distinzione dei casi non è regolarmente disponibile**

- - - 

**Riferimenti**

[Script FBK](https://www.epicentro.iss.it/coronavirus/open-data/calcolo_rt_italia.zip)

[EpiEstim](https://cran.r-project.org/package=EpiEstim)

[Nota metodologica FBK «Stime della trasmissibilità di SARS-CoV-2 in Italia»](https://www.epicentro.iss.it/coronavirus/open-data/rt.pdf)



**Fonti dati input**

Italia: Storicizzazione dei dati a cura di [onData](https://github.com/ondata/covid19italia/tree/master/webservices/iss_epicentro_dati) e [Andrea Mignone](https://github.com/floatingpurr/covid-19_sorveglianza_integrata_italia) a partire da ["COVID-19 ISS open data"](https://www.epicentro.iss.it/coronavirus/open-data/covid_19-iss.xlsx) di ISS

Lombardia: Storicizzazione dei dati a cura di [OpenCovid](https://github.com/opencovid-mr/Lombardia-Stati_Clinici/) a partire da ["Matrice degli stati clinici Covid-19 inviati a ISS"](https://hub.dati.lombardia.it/Sanit-/Matrice-degli-stati-clinici-Covid-19-inviati-a-ISS/7jw9-ygfv) di Regione Lombardia.

Regioni/PPAA (ricoveri): Dashboard [INFN-CovidStat](https://covid19.infn.it/iss/) realizzata utilizzando dati forniti da ISS esposti con [Licenza CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Storicizzazione parziale dei dati a cura di [OpenCovid](https://github.com/opencovid-mr/infn-iss).

Regioni/PPAA (sintomi): Dashboard [INFN-CovidStat](https://covid19.infn.it/iss/) realizzata utilizzando dati forniti da ISS esposti con [Licenza CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). 

 


- - -

**Grafici e stime aggiornate**


[Rt_sintomi Italia - ultimo aggiornamento](https://github.com/opencovid-mr/stima_rt/blob/main/output/Rt_sint/Rt_sint_Ita_updated_latest.csv)

![Last Plot Rt_sintomi Italia](https://github.com/opencovid-mr/stima_rt/blob/main/output/Rt_sint/Rt_sint_Ita_updated_latest.png)



[Rt_ricoveri Italia - ultimo aggiornamento](https://github.com/opencovid-mr/stima_rt/blob/main/output/Rt_hosp/Rt_hosp_Ita_updated_latest.csv)

![Last Plot Rt_ricoveri Italia](https://github.com/opencovid-mr/stima_rt/blob/main/output/Rt_hosp/Rt_hosp_Ita_updated_latest.png)



[Rt_sintomi Lombardia - ultimo aggiornamento](https://github.com/opencovid-mr/stima_rt/blob/main/output/regioneLombardia/Rt_sint_regLombardia_updated_latest.csv)

![Last Plot Rt_sintomi Lombardia](https://github.com/opencovid-mr/stima_rt/blob/main/output/regioneLombardia/Rt_sint_regLombardia_updated_latest.png)



