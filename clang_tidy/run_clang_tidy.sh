#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
JSONCPP_SRC="$PROJECT_ROOT/jsoncpp/src/lib_json"
JSONCPP_INC="$PROJECT_ROOT/jsoncpp/include"
BUILD_DIR="$PROJECT_ROOT/unit_tests/build"
OUTPUT_FILE="$SCRIPT_DIR/clang_tidy_report.txt"

echo "=== Priprema baze kompajliranja (compile_commands.json) ==="
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "$PROJECT_ROOT/jsoncpp" > /dev/null

echo "=== Pokretanje Clang-Tidy analize ==="

clang-tidy "$JSONCPP_SRC"/*.cpp -p "$BUILD_DIR" \
    --extra-arg=-std=c++11 \
    --extra-arg=-I"$JSONCPP_INC" \
    --header-filter="$JSONCPP_INC/.*" \
    -checks="*,-clang-diagnostic-error" \
    > "$OUTPUT_FILE" 2>&1

echo "=== Clang-Tidy analiza zavrsena. Izvestaj je u: $OUTPUT_FILE ==="

echo -e "\nRezime pronadjenih upozorenja:"
grep "\[.*\]" "$OUTPUT_FILE" | sed 's/.*\[\(.*\)\]/\1/' | sort | uniq -c | sort -nr
