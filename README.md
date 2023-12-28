# Užduotis

Sukurkite duomenų produktą - analitinę aplikaciją, skirtą banko paskolos įvertinimui mašininio mokymosi algoritmų pagalba.

# Projekto eiga

## Duomenų parengimas
Visų duomenų analizės procesų pradinis žingsnis yra duomenų parengimas jų apdorojimui ir analizei. Šiame projekte buvo taikomi žingsniai:
* Sample_data ir Additional_data sujungimas į vieną bendrą rinkinį;
* Pagal ID stulpelio reikšmes prijungti papildomi požymiai iš additional_features failo;
* Sudaryti mokymosi, testavimo ir validavimo rinkiniai pagal 70,15,15 proporciją;
* Faktorizuojami kategoriniai kintamieji - y, term (terminas), credit_score (kredito reitingas, nurodytas tekstinėmis reikšmėmis / kategorijomis), loan_purpose (paskolos tikslas), home_ownership (ar subjektui priklauso nekilnojamo turto).

## Modelio rengimas
Modeliui parengti naudota _h2o_ biblioteka ir jos metodas _h2o.automl_, kuris mašininio mokymosi pagalba sukuria klasifikavimo modelį.

### Galimi parametrai
h2o.automl galimi ir šiame projekte naudoti parametrai:
* kintamieji x ir y - kurie duomenų stulpeliai naudojami;
* seed - atsitiktinio generavimo reikšmė, norit išlaikyti modelio atkuriamuma;
* nfolds - tarpinių tikrinimų kiekis (angl. _cross-validation_) - kiek kartų mašininio mokymosi metu bus tikrinamas tikslumas tarp mokymosi ir validavimo rinkinių;
* include_algos - kokius metodus taikyti mokymosi metu;
* training_frame - mokymosi duomenų rinkinys;
* validation_frame - validavimo rinkinys;
* leaderboard_frame - rinkinys, pagal kurį matuojamas modelių tikslumas;
* sort_metric - pagal kokią reikšmę rikiuojami modeliai;
* stopping_metric - tikslinis kintamasis, pagal kurį galima nurodyti, kada nutraukti mašininį mokymąsi;
* max_models - maksimalus modelių skaičius;
* max_runtime_secs - maksimali mokymosi trukmė.

### Naudoti parametrai
Projekto metu, buvo bandomos įvairios variacijos skirtingų parametrų, dėl kurių kito modelio tikslumas čia pateikiami parametrai, ir kaip projekto eigoje jie kito.
* x - pradiniame variante nenurodyta, tačiau vėliau pastebėta, kad modeliams automatiškai neatrenkami likę stulpeliai, todėl nurodyti visi, išskyrus ID ir y kintamieji;
* y - pirmas stulpelis iš duomenų rinkinių (t.y. stulpelis "y");
* seed - 99 - įtakos modeliui beveik neturi (skirtingos reikšmės gali minimaliai pakeisti tikslumą dėl atsitiktinumo, bendruoju atveju į jį neatsižvelgta);
* nfolds - 0 - pradžioje nenaudotas parametras, tačiau vėliau pastebėta, kad nenurodžius jokios reikšmės, modeliai persimokydavo, todėl nurodyta nenaudoti tarpinio tikrinimo;
* include_algos - "GBM" - pirmųjų bandymų metu, pastebėta, kad visi geriausi modeliai naudoja sustiprinimo (angl. _Gradient boosting_) metodą, todėl taupant laiką ir kompiuterio resursus, nurodyta naudoti tiktais šitą metodą;
* training_frame - mokymosi duomenų rinkinys (70% pradinės duomenų imties);
* validation_frame - validavimo rinkinys (15% pradinės duomenų imties);
* leaderboard_frame - rinkinys, pagal kurį matuojamas modelių tikslumas (15% pradinės duomenų imties);
* sort_metric - "AUC" - modulio reikalavimuose nurodyta modelio tikslumui nustatyti naudoti plotą po kreive (angl. _area under curve_);
* stopping_metric - "AUC";
* max_models - 200 - naudota tiktais pradiniais taikymais, vėliau pastebėta, kad logiškiau uždėti laiko limitą, negu laukti kol bus apskaičiuoti visas nurodytas modelių skaičius;
* max_runtime_secs - 3600 sekundžių arba 1 valanda - dažnu atveju reikšmę pakėlus per daug, gaunama trūkstamos atminties klaida (angl. _out of memory_), todėl apsiribota viena valanda.

### Rezultatai
**Pateikiami rezultatai ne dėstytojo duomenims**
* Pirmo spėjimo metu (nenurodžius GBM algoritmo ir nfolds reikšmės, nefaktorizavus kitamųjų ) - 0.703;
* Antro spėjimo metu (naudojami tiktais pirmas milijonas duomenų GBM algoritmas, faktorizavus duomenis) - 0.782;
* Trečio spėjimo metu (GBM algoritmas, nfolds = 0, visi 10 milijonų duomenų, faktorizuoti kintamieji) - 0.830.

Dėstytojui pateiktos trys skirtingos paskutinio algoritmo iteracijos, gauti rezultatai:
* Pirmas spėjimas - 0.8207;
* Antras spėjimas - 0.8228;
* Trečias spėjimas - 0.8296.

## Shiny aplikacija
