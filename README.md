# stima_rt

Codice R per stimare indice Rt_sintomi e Rt_ricoveri dell'Italia

**Le stime dei giorni più recenti (14 per Rt_sintomi, 7 giorni per Rt_ricoveri) sono sottostime in quanto derivano da dati non consolidati**

**Le stime sono calcolate senza distinzione tra casi autoctoni e casi importati in quanto tale distinzione dei casi non è regolarmente disponibile**

- - - 

**Riferimenti**

[Script FBK](https://www.epicentro.iss.it/coronavirus/open-data/calcolo_rt_italia.zip)

[EpiEstim](https://cran.r-project.org/package=EpiEstim)

[Nota metodologica FBK «Stime della trasmissibilità di SARS-CoV-2 in Italia»](https://www.epicentro.iss.it/coronavirus/open-data/rt.pdf)



**Fonte dati input**

Storicizzazione dei dati a cura di [onData](https://github.com/ondata/covid19italia/tree/master/webservices/iss_epicentro_dati) e [Andrea Mignone](https://github.com/floatingpurr/covid-19_sorveglianza_integrata_italia) a partire da ["COVID-19 ISS open data"](https://www.epicentro.iss.it/coronavirus/open-data/covid_19-iss.xlsx) di ISS

- - -

**Grafici e stime aggiornate**


[Rt_sintomi - ultimo aggiornamento](https://github.com/opencovid-mr/stima_rt/blob/main/output/Rt_sint/Rt_sint_Ita_updated_latest.csv)

![Last Plot Rt_sintomi](https://github.com/opencovid-mr/stima_rt/blob/main/output/Rt_sint/Rt_sint_Ita_updated_latest.png)



[Rt_ricoveri - ultimo aggiornamento](https://github.com/opencovid-mr/stima_rt/blob/main/output/Rt_hosp/Rt_hosp_Ita_updated_latest.csv)

![Last Plot Rt_ricoveri](https://github.com/opencovid-mr/stima_rt/blob/main/output/Rt_hosp/Rt_hosp_Ita_updated_latest.png)



