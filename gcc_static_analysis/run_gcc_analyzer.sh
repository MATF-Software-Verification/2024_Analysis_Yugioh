#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
JSONCPP_SRC="$PROJECT_ROOT/jsoncpp/src/lib_json"
JSONCPP_INC="$PROJECT_ROOT/jsoncpp/include"
OUTPUT_FILE="$SCRIPT_DIR/gcc_analyzer_report.txt"

echo "=== Pokretanje GCC Static Analyzer (-fanalyzer) ==="
echo "Analiziram fajlove u $JSONCPP_SRC..."

# Pokrecemo g++ sa -fanalyzer opcijom
# -c: Samo kompajliraj (ne linkuj), jer zelimo analizu source fajlova
# -fanalyzer: Ukljuci staticku analizu (dostupno od GCC 10+)
# -std=c++11: Standard koji projekat koristi
# -I: Putanja do headera
# -Wno-psabi: Iskljuci dosadna upozorenja o ABI promenama (ako se pojave)

rm -f "$OUTPUT_FILE"

for file in "$JSONCPP_SRC"/*.cpp; do
    filename=$(basename "$file")
    echo "Analiziram: $filename"
    
    g++ -c -fanalyzer \
        -std=c++11 \
        -I "$JSONCPP_INC" \
        "$file" \
        -o /dev/null \
        2>> "$OUTPUT_FILE"
done

echo "=== GCC Static Analyzer zavrsen. Izvestaj je u: $OUTPUT_FILE ==="

WARNING_COUNT=$(grep -c "warning:" "$OUTPUT_FILE")
echo "Pronadjeno $WARNING_COUNT upozorenja."
