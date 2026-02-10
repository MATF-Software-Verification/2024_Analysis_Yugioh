# Analiza jsoncpp projekta

## Informacije o autoru
- **Ime i prezime:** Marko Bura
- **Broj indeksa:** 1040/2024

## O projektu
**jsoncpp** je C++ biblioteka za rad sa JSON podacima (serijalizacija i deserijalizacija).
- **Izvorni kod:** [jsoncpp](https://github.com/open-source-parsers/jsoncpp)
- **Analizirana verzija (commit):** `b511d9e64956db998b74909df112ac8c8f41d6ff`

## Korišćeni alati
1. **Testovi i pokrivenost koda (gcov/lcov)**
   - Alat se koristi za pokretanje postojećih i novih testova, uz merenje procenta izvršenog koda.
   - **Instrukcije:** Pokrenuti skriptu `./unit_tests/run_tests.sh`. Izveštaji će biti generisani u `unit_tests/reports/`.
2. **Valgrind (Memcheck)**
   - Alat za dinamičku analizu memorije. Koristi se za pronalaženje curenja memorije i neispravnih pristupa memoriji.
   - **Instrukcije:** Pokrenuti skriptu `./valgrind_memcheck/run_memcheck.sh`. Rezultat je sačuvan u `valgrind_memcheck/memcheck_out.txt`.

## Zaključci
- Biblioteka `jsoncpp` ima veoma visoku pokrivenost koda originalnim testovima (preko 95%).
- Dodavanjem ciljanih testova za *move* semantiku i specifične konfiguracije parsera, pokrivenost je uspešno povećana, što potvrđuje modularnost koda.
