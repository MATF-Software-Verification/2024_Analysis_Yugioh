#!/bin/bash

# Putanje
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
JSONCPP_SRC="$PROJECT_ROOT/jsoncpp/src/lib_json"
JSONCPP_INC="$PROJECT_ROOT/jsoncpp/include"
OUTPUT_FILE="$SCRIPT_DIR/cppcheck_report.txt"

echo "=== Pokretanje Cppcheck analize ==="

# Pokrecemo cppcheck sa:
# --enable=all (sve provere: warning, performance, portability, style...)
# --inconclusive (prikazi i potencijalne greske koje nisu 100% sigurne)
# --std=c++11 (standard koji biblioteka koristi)
# -I (putanja do headera)
# --suppress (opciono, ako zelimo da preskocimo neke sistemske greske)
# --output-file (gde cuvamo rezultat)

cppcheck --enable=all \
         --inconclusive \
         --std=c++11 \
         -I "$JSONCPP_INC" \
         "$JSONCPP_SRC" \
         2> "$OUTPUT_FILE"

echo "=== Cppcheck analiza zavrsena. Izvestaj je u: $OUTPUT_FILE ==="

# Ispisivanje rezimea (broj pronadjenih stavki po kategorijama)
echo -e "\nRezime pronadjenih stavki:"
grep -o "\[.*\]" "$OUTPUT_FILE" | sort | uniq -c | sort -nr
