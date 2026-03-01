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
3. **Clang-Tidy**
   - Alat za statičku analizu koda koji proverava usklađenost sa stilom i pronalazi potencijalne logičke greške.
   - **Instrukcije:** Pokrenuti skriptu `./clang_tidy/run_clang_tidy.sh`. Izveštaj se nalazi u `clang_tidy/clang_tidy_report.txt`.
4. **Cppcheck**
   - Alat za statičku analizu C/C++ koda koji se fokusira na bagove, nedefinisano ponašanje i opasne konstrukcije koda.
   - **Instrukcije:** Pokrenuti skriptu `./cppcheck/run_cppcheck.sh`. Izveštaj se nalazi u `cppcheck/cppcheck_report.txt`.
5. **GCC Static Analyzer**
   - Staticka analiza ugradjena u GCC kompajler (`-fanalyzer`). Detektuje curenje memorije, double-free, use-after-free, itd.
   - **Instrukcije:** Pokrenuti skriptu `./gcc_static_analysis/run_gcc_analyzer.sh`. Izveštaj se nalazi u `gcc_static_analysis/gcc_analyzer_report.txt`.
6. **Lizard**
   - Alat za merenje kompleksnosti koda (Cyclomatic Complexity Number - CCN). Ukazuje na funkcije koje su teske za odrzavanje i testiranje.
   - **Instrukcije:** Pokrenuti skriptu `./lizard_analysis/run_lizard.sh`. Skripta automatski kreira Python virtuelno okruzenje i instalira alat. Izveštaj se nalazi u `lizard_analysis/lizard_report.txt`.

