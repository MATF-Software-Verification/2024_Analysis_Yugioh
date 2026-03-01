# Projekat: Analiza softvera biblioteke jsoncpp
**Student:** Marko Bura (1040/2024)

Ovaj izveštaj detaljno opisuje primenu 6 alata za verifikaciju softvera na open-source projektu `jsoncpp`. Fokus analize je bio na pronalaženju bagova, merenju pokrivenosti koda, analizi memorije i proceni složenosti i održivosti koda.

---

## 1. Analiza pokrivenosti koda (Unit Tests & Coverage)

### Opis analize
Prvi korak u verifikaciji bilo je merenje efikasnosti postojećih testova. Cilj je bio identifikovati "crvene zone" – delove koda koji se nikada ne izvršavaju, što predstavlja rizik jer ti delovi koda mogu sadržati skrivene bagove.

### Proces rada
1. Napravio sam automatizovanu skriptu `run_tests.sh` koja prevodi biblioteku sa flegovima za pokrivenost (`-fprofile-arcs -ftest-coverage`).
2. Pokrenuo sam originalne testove biblioteke.
3. Analizom `original_filtered.info` fajla, identifikovao sam potencijalne praznine u `json_reader.cpp` i `json_value.cpp`.
4. Napisao sam dodatni test u `my_tests.cpp` koji je gađao:
   - `allowDroppedNullPlaceholders_` opciju u parseru (`json_reader.cpp`, linije 199-208).
5. Pokušao sam i sa dodatnim testovima za *move* semantiku i konverzije tipova, ali oni nisu doveli do povećanja broja pokrivenih linija.
6. Analiza je pokazala da je `json_reader.cpp` skočio sa 960 pokrivenih linija na 968.

### Rezultati
- **Originalna pokrivenost**: 95.3% linija.
- **Identifikovane praznine**: Primetio sam da specifične opcije parsera (poput `allowDroppedNullPlaceholders_`) u `json_reader.cpp` (linije 199-208) nisu bile pokrivene u originalnim testovima.
- **Poboljšanje**: Mojim testovima pokrivenost je porasla na **95.6%**. Iako sam pokušao da povećam pokrivenost i u drugim delovima biblioteke (npr. *move* semantika u `json_value.cpp`), analiza je pokazala da te grane koda ne donose nove linije pokrivenosti jer su već bile delimično pokrivene indirektno. Najveći uspeh je bio u parseru gde sam aktivirao 8 potpuno novih linija koda.

### Zaključak
Analiza pokrivenosti koda je pokazala da čak i projekti sa veoma visokom početnom pokrivenošću (preko 95%) mogu imati kritične delove koda koji nisu testirani. Kroz ovaj alat sam naučio da identifikujem takve praznine i napišem ciljane testove za specifične funkcionalnosti (poput parser opcija), čime se direktno povećava pouzdanost i robusnost softvera.

---

## 2. Dinamička analiza memorije (Valgrind Memcheck)

### Opis analize
Pošto je `jsoncpp` C++ biblioteka koja intenzivno koristi dinamičku memoriju za čuvanje JSON stabla, neophodno je proveriti da li dolazi do curenja memorije (*memory leaks*) ili neispravnih pristupa (*invalid reads/writes*).

### Proces rada
1. Kreirao sam skriptu `valgrind_memcheck/run_memcheck.sh`.
2. Izvršne fajlove originalnih testova sam pokrenuo pod nadzorom `valgrind` alata sa modulom `--tool=memcheck`.
3. Rezultate sam sačuvao u `memcheck_out.txt`.

### Rezultati
- **Nalazi**: "0 errors from 0 contexts". Biblioteka je veoma stabilna u pogledu upravljanja memorijom.
- **Diskusija**: Prijavljeno je da je određena količina memorije ("still reachable") ostala u memoriji. Analiza je pokazala da to nisu bagovi, već statički objekti unutar `jsontest` frejmvorka koji se oslobađaju tek po završetku procesa, što je očekivano ponašanje.

### Zaključak
Korišćenjem Valgrind Memcheck alata, potvrdio sam da je `jsoncpp` biblioteka izuzetno stabilna u pogledu upravljanja memorijom. Odsustvo "definitely lost" grešaka mi uliva poverenje u kvalitet destruktora i interne logike za alokaciju.

---

## 3. Statička analiza (Clang-Tidy)

### Opis analize
`Clang-Tidy` je moćan alat za statičku analizu koda baziran na LLVM-u. Njegova uloga je da "pročita" izvorni kod bez pokretanja programa i identifikuje kršenja stilskih pravila, zastarele C++ konstrukcije i potencijalne logičke greške koje bi mogle postati bagovi u budućnosti.

### Proces rada
1. **Generisanje baze kompilacije**: Pomoću CMake-a sam generisao `compile_commands.json` fajl. Ovo je neophodno jer `clang-tidy` mora da zna tačne parametre kompilacije (include putanje, definisane makroe) da bi ispravno analizirao kod.
2. **Konfiguracija provera**: U skripti `run_clang_tidy.sh` sam uključio sve dostupne provere (`checks="*"`) kako bih dobio najdetaljniji mogući uvid u stanje koda.
3. **Automatizacija**: Skripta je obradila sve `.cpp` fajlove biblioteke u `src/lib_json/` folderu i generisala obiman izveštaj od preko 7000 linija.

### Rezultati
Analiza je otkrila značajan "tehnički dug" u biblioteci `jsoncpp`. Najzanimljiviji su bili nalazi u kategoriji **`bugprone-branch-clone`**, gde sam identifikovao konkretna mesta u kodu sa dupliranom ili sumnjivom logikom:

- **Primer 1 (Nepotpuno rukovanje greškama)**: U fajlu `json_value.cpp` (linija 1686), identifikovao sam `if-else` blok gde su prve dve grane identične jer sadrže samo komentare (npr. `// Error: missing argument`). Ovo je jasan dokaz "nezavršenog posla" u kodu gde su programeri predvideli mesta za obradu grešaka, ali ih nisu implementirali.
- **Primer 2 (Duplirana logika)**: U fajlu `json_writer.cpp` (linija 34), alat je markirao grane koje obrađuju negativne brojeve kao identične. Iako je logika ispravna, alat sugeriše da bi se ovaj deo koda mogao refaktorisati radi bolje čitljivosti.
- **Modernizacija koda (`modernize-*`)**: Pronašao sam na stotine mesta gde se koriste zastareli C++98 koncepti (npr. `NULL` umesto `nullptr`), što ukazuje na potrebu za osvežavanjem koda prema novijim standardima.
- **Čitljivost i stil (`google-*`)**: Primetio sam veliki broj upozorenja zbog nedostatka vitičastih zagrada u kratkim `if` blokovima, što je protivno modernim preporukama za sigurno programiranje.

### Zaključak
Iako je biblioteka `jsoncpp` stabilna, `Clang-Tidy` mi je omogućio da lociram konkretna mesta u kodu koja su konfuzna ili zastarela. Posebno su mi bili korisni primeri poput praznih grana za greške, jer to su stvari koje bi čovek teško primetio običnim čitanjem koda, a koje statička analiza nepogrešivo pronalazi.

---

## 4. Dodatna statička analiza (Cppcheck)

### Opis analize
`Cppcheck` je alat fokusiran na pronalaženje stvarnih bagova i nedefinisanog ponašanja, a ne na stil koda. Izabrao sam ga jer nije obrađivan na vežbama.

### Proces rada
1. Kreirao sam folder `cppcheck` i skriptu `run_cppcheck.sh`.
2. Analizu sam pokrenuo sa opcijama `--enable=all` i `--inconclusive`.

### Rezultati
Analiza je generisala izveštaj sa nekoliko veoma značajnih nalaza, koje sam detaljno proanalizirao:

- **`arrayIndexOutOfBounds` (Potencijalni ozbiljan bag)**:
  Pronašao sam ovaj nalaz u funkciji `OurReader::match` (`json_reader.cpp`, linija 1271). Alat tvrdi da se pristupa nizu van granica (npr. indeks 6 za niz veličine 3).
  *Analiza*: Utvrdio sam da je ovo **lažno pozitivan** rezultat. Funkcija `match` je generička i prima različite stringove (npr. `"true"` dužine 4 i `"nfinity"` dužine 7). Cppcheck je pogrešno povezao veličinu iz jednog poziva sa logikom drugog. Ipak, ovaj nalaz je koristan jer ukazuje na kritičan deo koda gde bi pogrešno prosleđena dužina stringa zaista srušila program.

- **`unreachableCode` (Mrtav kod)**:
  U fajlu `json_value.cpp` na liniji 143, alat je markirao kod unutar makroa `JSON_ASSERT_MESSAGE` kao nedostižan.
  *Analiza*: Ovo je posledica kompleksne ekspanzije makroa za asercije. Alat vidi da makro može da pozove `abort()`, i u određenim konfiguracijama pretpostavlja da će se to uvek desiti, markirajući ostatak funkcije kao nepotreban. Ovo mi je ukazalo na to koliko makroi mogu da otežaju automatsku analizu koda.

- **`noExplicitConstructor` (20 nalaza)**:
  Detektovao sam veliki broj konstruktora sa jednim argumentom koji nisu obeleženi ključnom rečju `explicit`.
  *Analiza*: Ovo je najčešći nalaz. Iako program radi ispravno, nedostatak `explicit` omogućava "tihe" konverzije (npr. da se broj automatski pretvori u `Json::Value` tamo gde to možda nismo hteli), što otežava debagovanje velikih sistema.

- **`constParameter`**:
  Identifikovao sam 6 mesta gde parametri funkcija mogu biti deklarisani kao `const`. To bi omogućilo kompajleru bolju optimizaciju i sprečilo slučajne izmene podataka.

### Zaključak
`Cppcheck` mi je pružio dragocen uvid u logičku ispravnost koda. Posebno mi je bilo korisno da istražim `arrayIndexOutOfBounds` nalaz, jer me je to nateralo da duboko razumem kako parser funkcioniše. Čak i tamo gde je alat dao lažnu uzbunu, on je ukazao na "škakljiva" mesta u kodu koja su najpodložnija ljudskoj grešci prilikom budućih izmena.

---

## 5. Napredna statička analiza (GCC Static Analyzer)

### Opis analize
Koristio sam najnoviji GCC-ov alat `-fanalyzer`. On vrši interproceduralnu analizu (prati tok podataka kroz više funkcija), što je mnogo naprednije od običnih lintera.

### Proces rada
1. Skripta `run_gcc_analyzer.sh` je pokrenula `g++` sa `-fanalyzer` zastavicom.
2. Rezultate sam prikupio u `gcc_analyzer_report.txt`.

### Rezultati
Analiza je bila veoma detaljna i fokusirana na modul `json_value.cpp`. Pronašao sam dva tipa upozorenja koja ukazuju na konzervativan pristup alata, ali i na kritične delove koda:

- **Potencijalno curenje memorije (`-Wanalyzer-malloc-leak`)**:
  U funkciji `duplicateAndPrefixStringValue` (`json_value.cpp`, linija 147), alat me je upozorio na curenje memorije alocirane pomoću `malloc`.
  *Analiza*: Utvrdio sam da je ovo **lažno pozitivan** rezultat. Memorija se alocira u pomoćnoj funkciji koja vraća pokazivač, a on se kasnije dodeljuje objektu klase `Value` čiji destruktor osigurava oslobađanje. Alat ovde nije uspeo da isprati prenos vlasništva kroz ceo životni ciklus objekta, ali je nalaz koristan jer markira mesta gde se memorijom upravlja manuelno (sirovi pokazivači).

- **Upotreba potencijalnog NULL pokazivača (`-Wanalyzer-possible-null-argument`)**:
  Na liniji 1035 u `json_value.cpp`, alat je prijavio da `operator new` može vratiti `NULL` u slučaju neuspešne alokacije, a da se ta vrednost koristi bez provere.
  *Analiza*: Ovo je takođe **tehnička uzbuna**. U standardnom C++ okruženju sa izuzecima, `new` će baciti `std::bad_alloc` pre nego što vrati `NULL`. Ipak, ovaj nalaz je značajan za sisteme gde su izuzeci isključeni, jer bi tada ovaj deo koda zaista doveo do pada programa.

### Zaključak
GCC Static Analyzer mi je pružio uvid u najdublje slojeve biblioteke gde se vrši direktna manipulacija memorijom. Iako su pronađeni nalazi lažno pozitivni u kontekstu standardnog korišćenja, oni su mi precizno ukazali na "najslabije karike" u implementaciji – mesta gde bi i najmanja greška u logici upravljanja vlasništvom dovela do curenja.

---

## 6. Analiza kompleksnosti koda (Lizard)

### Opis analize
Kao poslednji alat u mojoj analizi izabrao sam `Lizard`. Odlučio sam se za ovaj alat jer on pruža kvantitativne metrike o samom dizajnu koda, prvenstveno kroz **ciklomatsku kompleksnost (CCN)**. Dok su prethodni alati bili usmereni na pronalaženje bagova i curenja memorije, `Lizard` mi je omogućio da ocenim **održivost** i **čitljivost** koda. Visoka kompleksnost često ukazuje na delove koda koji su teški za testiranje i održavanje, jer svaka mala promena može lako dovesti do novih, neočekivanih problema.

### Proces rada
1. Kreirao sam Python virtualno okruženje i instalirao `lizard` kako bih osigurao izolovanost i portabilnost analize.
2. Napisao sam skriptu `run_lizard.sh` koja automatski sortira nalaze po nivou kompleksnosti, čime sam odmah identifikovao najkritičnije tačke u kodu.
3. Analizu sam sproveo nad kompletnim izvornim kodom biblioteke u `src/lib_json/`.

### Rezultati
Analiza je otkrila postojanje nekoliko izuzetno složenih funkcija koje predstavljaju izazov za održavanje:
- **`Json::OurReader::readToken`** ima CCN vrednost od čak **109**! Ovo je nivo kompleksnosti koji se u softverskom inženjerstvu smatra ekstremno visokim i rizičnim (granica stabilnosti je obično CCN 50). Detaljnim pregledom ove funkcije u `json_reader.cpp`, primetio sam da ona sadrži ogroman broj `switch` i `if` blokova koji obrađuju svaki pojedinačni karakter JSON-a, što je čini veoma teškom za potpuno razumevanje i testiranje.
- **`Json::Reader::readToken`** prati sa CCN **70**, dok funkcija **`readValue`** ima CCN **19** (za obe implementacije čitača).
- Prosečna kompleksnost po funkciji je prihvatljiva, ali ovi "ekstremi" u parseru ukazuju na to da je logika čitanja JSON-a implementirana kroz masivne, monolitne funkcije.

### Zaključak
Rezultati Lizard analize su mi objasnili zašto su neki drugi alati (poput GCC Static Analyzer-a) imali poteškoća da isprate sve putanje kroz kod. Biblioteka `jsoncpp` se oslanja na nekoliko ključnih, ali prekompleksnih funkcija. Kroz ovaj alat sam shvatio da funkcionalna ispravnost nije isto što i kvalitet dizajna – iako kod radi bez greške, njegova visoka kompleksnost u parseru predstavlja značajan **tehnički dug** koji otežava buduće unapređenje biblioteke.

---

## Zaključak projekta

Kroz primenu ovih šest alata, stekao sam dubok i objektivan uvid u kvalitet biblioteke `jsoncpp`. Moja završna zapažanja su sledeća:

1.  **Funkcionalna stabilnost**: Pomoću **Unit testova** i **Valgrind Memcheck-a** potvrdio sam da je biblioteka izuzetno robusna. Postojeći testovi pokrivaju preko 95% koda, a dinamička analiza nije pokazala nijedno kritično curenje memorije, što je impresivno za C++ projekat ove veličine.
2.  **Logička ispravnost**: Alatima **Cppcheck** i **GCC Static Analyzer** ušao sam "ispod haube" i analizirao najkompleksnije delove koda. Iako su mnogi nalazi bili lažno pozitivni, oni su mi ukazali na rizična mesta gde se memorijom upravlja manuelno i gde su algoritmi za parsiranje toliko kompleksni da ih čak i napredni statički analizatori teško prate.
3.  **Kvalitet koda i modernizacija**: **Clang-Tidy** mi je jasno stavio do znanja da biblioteka nosi značajan "tehnički dug". Veliki broj sumnjivih `branch-clone` struktura i hiljade upozorenja o zastarelim C++ konstrukcijama govore da je kodu neophodno ozbiljno osvežavanje.
4.  **Dizajn i održivost**: **Lizard** je kvantifikovao ono što sam primetio tokom manuelnog pregleda – parser se oslanja na nekoliko ekstremno kompleksnih funkcija (CCN > 100). Ovo je ključna tačka gde se funkcionalna ispravnost sukobljava sa održivošću: iako kod radi savršeno, njegova kompleksnost ga čini teškim za buduće izmene.

**Konačni sud**: Biblioteka `jsoncpp` je pouzdan i zreo softver, ali pati od visoke kompleksnosti i zastarele implementacije u pojedinim delovima. Moja preporuka je refaktorisati monolitne funkcije parsera na manje, testabilnije celine i primeniti automatsku modernizaciju koda (nullptr, auto, override), čime bi se značajno olakšalo dalje održavanje i smanjio rizik od uvođenja novih grešaka.
