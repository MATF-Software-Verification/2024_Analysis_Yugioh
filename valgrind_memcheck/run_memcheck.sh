#!/bin/bash

# Putanje
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
BUILD_DIR="$PROJECT_ROOT/unit_tests/build"
ORIGINAL_TEST_EXE="$BUILD_DIR/bin/jsoncpp_test"
OUTPUT_FILE="$SCRIPT_DIR/memcheck_out.txt"

if [ ! -f "$ORIGINAL_TEST_EXE" ]; then
    echo "ERROR: Original test executable not found! Run unit_tests/run_tests.sh first."
    exit 1
fi

echo "=== Valgrind Memcheck Report: Original Unit Tests ===" > "$OUTPUT_FILE"
echo "Generated on: $(date)" >> "$OUTPUT_FILE"

echo "--- Running Valgrind on Original Unit Tests (jsoncpp_test) ---"
valgrind --leak-check=full \
         --show-leak-kinds=all \
         --track-origins=yes \
         --log-file="/tmp/valgrind_tmp.txt" \
         "$ORIGINAL_TEST_EXE"

cat "/tmp/valgrind_tmp.txt" >> "$OUTPUT_FILE"
rm "/tmp/valgrind_tmp.txt"

echo "=== Valgrind analiza zavrsena. Izvestaj je u: $OUTPUT_FILE ==="

grep -E "ERROR SUMMARY|definitely lost" "$OUTPUT_FILE"
