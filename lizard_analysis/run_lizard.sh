#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
JSONCPP_SRC="$PROJECT_ROOT/jsoncpp/src/lib_json"
VENV_DIR="$SCRIPT_DIR/venv"
OUTPUT_FILE="$SCRIPT_DIR/lizard_report.txt"

echo "=== Priprema okruzenja za Lizard (Ciklomatska kompleksnost) ==="

if [ ! -d "$VENV_DIR" ]; then
    echo "Kreiram Python virtualno okruzenje..."
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

if ! command -v lizard &> /dev/null; then
    echo "Instaliram lizard unutar virtualnog okruzenja..."
    pip install lizard
fi

echo "=== Pokretanje Lizard analize ==="
echo "Analiziram fajlove u: $JSONCPP_SRC"

# Pokrecemo lizard
# -l cpp: Jezik C++
# -C 15: Prikazi samo funkcije sa kompleksnoscu vecom od 15 (filter)
# -w: Prikazi upozorenja
# Pokrecemo lizard i filtriramo samo funkcije (one sadrze @ u lokaciji)
# Sortiramo po 2. koloni (CCN) opadajuce i uklanjamo duplikate
lizard -l cpp "$JSONCPP_SRC" | grep "@" | sort -nr -k2 | uniq > "$OUTPUT_FILE"

echo "=== Lizard analiza zavrsena. Izvestaj je u: $OUTPUT_FILE ==="

echo -e "\nTOP 10 najkompleksnijih funkcija (po CCN - Cyclomatic Complexity Number):"
echo "CCN  | LOC  | Funkcija"
echo "----------------------------------------------------------------"
grep -v "NLOC" "$OUTPUT_FILE" | grep -v "total" | sort -nr -k2 | uniq | head -n 10

deactivate
