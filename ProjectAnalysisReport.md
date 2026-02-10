# Izveštaj o analizi projekta jsoncpp

## 1. Analiza pokrivenosti koda (Unit Tests & Coverage)

### Opis analize
Prvi korak analize bio je utvrđivanje trenutnog stanja testova unutar `jsoncpp` biblioteke. Korišćen je alat `lcov` u kombinaciji sa `gcov` kako bi se dobio vizuelni izveštaj o tome koji delovi koda su pokriveni postojećim testovima.

### Proces rada
1. Napravljena je automatizovana skripta `run_tests.sh` koja prevodi biblioteku sa flegovima za pokrivenost (`-fprofile-arcs -ftest-coverage`).
2. Pokrenuti su originalni testovi biblioteke.
3. Analizom `original_filtered.info` fajla, identifikovani su delovi koda u `json_reader.cpp` i `json_value.cpp` koji nisu bili pokriveni.
4. Napisani su dodatni testovi u `my_tests.cpp` koji su gađali:
   - `allowDroppedNullPlaceholders_` opciju u parseru.
   - *Move constructor* i *move assignment* operatore u `Value` klasi.
   - Dodatne provere za poređenje vrednosti i konverziju tipova.

### Rezultati
- **Originalna pokrivenost:** 95.3% (2482 od 2604 linija)
- **Pokrivenost nakon dodatih testova:** 95.6% (2490 od 2604 linija)

### Zaključak
Biblioteka je izuzetno dobro testirana. Većina nepokrivenog koda (preostalih ~4%) odnosi se na specifične sistemske greške (npr. neuspešna alokacija memorije) ili ekstremno retke slučajeve koji zahtevaju promenu build okruženja. Analiza je uspešno pokazala kako se ciljanim testiranjem može unaprediti čak i veoma stabilan projekat.
