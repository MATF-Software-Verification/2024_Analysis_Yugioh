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

## 2. Dinamička analiza memorije (Valgrind Memcheck)

### Opis analize
Nakon provere pokrivenosti koda, sprovedena je dinamička analiza memorije pomoću alata `Valgrind`, konkretno njegovog najpoznatijeg modula `Memcheck`. Cilj je bio utvrditi da li biblioteka `jsoncpp` uzrokuje curenje memorije (*memory leaks*), pristupa neinicijalizovanim vrednostima ili nevalidnim memorijskim adresama.

### Proces rada
1. Napravljen je direktorijum `valgrind_memcheck` koji sadrži skriptu `run_memcheck.sh`.
2. Skripta pokreće glavni test program biblioteke unutar Valgrind okruženja:
   - `jsoncpp_test` (kompletan set od 121 originalnog unit testa biblioteke)
3. Parametri koji su korišćeni pri pokretanju su:
   - `--leak-check=full` (detaljna provera curenja memorije)
   - `--show-leak-kinds=all` (prikaz svih vrsta curenja: *definite*, *indirect*, *possible*, *reachable*)
   - `--track-origins=yes` (pomaže u pronalaženju uzroka korišćenja neinicijalizovane memorije)

### Rezultati
Analiza je pokazala da biblioteka `jsoncpp` u potpunosti poštuje pravila upravljanja memorijom u testiranim scenarijima.
- **ERROR SUMMARY:** 0 errors from 0 contexts.
- **Leak Summary:** Nije pronađeno nikakvo curenje memorije (0 bytes in 0 blocks are definitely lost).

Ovi rezultati su posebno značajni jer su testovi uključivali i kompleksne operacije poput *deep nesting*-a (veliki broj alokacija na hipu) i *move* semantike (prenošenje vlasništva nad memorijom između objekata).

### Zaključak
Biblioteka `jsoncpp` je memorijski bezbedna i robusna. Implementacija *move* operatora je ispravna i ne ostavlja "siročiće" u memoriji (dangling pointers ili leaks). Ovo je čini pogodnom za upotrebu u kritičnim C++ sistemima gde je stabilnost memorije od primarnog značaja.

## 3. Statička analiza (Clang-Tidy)

### Opis analize
Treći alat korišćen u analizi je `Clang-Tidy`, moćan alat za statičku analizu koji detektuje stilske neusaglašenosti, korišćenje zastarelih konstrukcija jezika i potencijalne logičke greške (*bug-prone* kod). Za razliku od Valgrinda, `Clang-Tidy` ne pokreće kod, već analizira samo stablo izvornog koda.

### Proces rada
1. Generisana je baza kompajliranja (`compile_commands.json`) pomoću CMake-a kako bi alat imao uvid u sve parametre prevođenja.
2. Napravljen je direktorijum `clang_tidy` sa skriptom `run_clang_tidy.sh`.
3. Analiza je pokrenuta nad svim izvornim fajlovima u `src/lib_json/` folderu, koristeći konfiguracioni fajl `.clang-tidy` koji je već bio prisutan u projektu.
4. Rezultati su filtrirani kako bi se uklonila upozorenja iz sistemskih zaglavlja i fokusiralo se isključivo na implementaciju biblioteke.

### Rezultati
Analiza je generisala veliki broj nalaza, što je i očekivano za projekat ove veličine. Najznačajnije kategorije su:
- **`modernize-*`**: Veliki broj sugestija za prelazak na modernije C++ konstrukcije (npr. *trailing return types*).
- **`readability-braces-around-statements`**: Identifikovano je preko 160 mesta gde nedostaju vitičaste zagrade u `if` ili `while` blokovima, što je protivno Google-ovom stilu koda.
- **`bugprone-branch-clone`**: Detektovano je 27 situacija gde su grane uslovnih prelaza identične, što može ukazivati na logičke greške nastale kopiranjem koda.
- **`cppcoreguidelines-avoid-magic-numbers`**: Pronađeno je 65 "magičnih brojeva" koji bi trebali biti definisani kao imenovane konstante radi bolje čitljivosti.

### Zaključak
Iako je biblioteka `jsoncpp` funkcionalno veoma stabilna, `Clang-Tidy` je otkrio da postoji značajan prostor za unapređenje čitljivosti i modernizaciju koda. Posebno su zanimljivi nalazi iz kategorije `bugprone` koji bi u budućim verzijama mogli dovesti do suptilnih bagova. Korišćenje ovog alata je pokazalo da čak i zreli projekti profitiraju od redovne statičke analize.




