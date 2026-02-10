#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
JSONCPP_DIR="$PROJECT_ROOT/jsoncpp"
BUILD_DIR="$SCRIPT_DIR/build"
REPORTS_DIR="$SCRIPT_DIR/reports"

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Ciscenje i priprema ===${NC}"
rm -rf "$BUILD_DIR"
rm -rf "$REPORTS_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$REPORTS_DIR"

echo -e "${GREEN}=== Konfiguracija i bildovanje originalnog projekta ===${NC}"
cd "$BUILD_DIR"
cmake -DCMAKE_CXX_FLAGS="-fprofile-arcs -ftest-coverage" \
      -DJSONCPP_WITH_TESTS=ON \
      -DJSONCPP_WITH_POST_BUILD_UNITTEST=OFF \
      "$JSONCPP_DIR"
make -j$(nproc)

echo -e "${GREEN}=== Pokretanje originalnih testova ===${NC}"
ctest --output-on-failure

echo -e "${GREEN}=== Generisanje izvestaja za originalne testove ===${NC}"
lcov --capture --directory . --output-file original.info
lcov --extract original.info "$JSONCPP_DIR/src/lib_json/*" --output-file original_filtered.info
genhtml original_filtered.info --output-directory "$REPORTS_DIR/original"

echo -e "${GREEN}=== Kompajliranje i pokretanje nasih testova ===${NC}"
g++ -std=c++11 -fprofile-arcs -ftest-coverage -I"$JSONCPP_DIR/include" \
    "$SCRIPT_DIR/tests/my_tests.cpp" \
    "$BUILD_DIR/lib/libjsoncpp.a" \
    -lpthread \
    -o "$BUILD_DIR/my_tests_exe"

export LD_LIBRARY_PATH="$BUILD_DIR/lib:$LD_LIBRARY_PATH"
"$BUILD_DIR/my_tests_exe"

echo -e "${GREEN}=== Generisanje zajednickog izvestaja ===${NC}"
lcov --capture --directory . --output-file combined.info
lcov --extract combined.info "$JSONCPP_DIR/src/lib_json/*" --output-file combined_filtered.info
genhtml combined_filtered.info --output-directory "$REPORTS_DIR/combined"

echo -e "${GREEN}=== ANALIZA POBOLJSANJA ===${NC}"
ORIGINAL_LINES=$(lcov --summary original_filtered.info | grep "lines" | cut -d' ' -f4)
COMBINED_LINES=$(lcov --summary combined_filtered.info | grep "lines" | cut -d' ' -f4)

echo -e "Originalna pokrivenost linija: ${ORIGINAL_LINES}"
echo -e "Zajednicka pokrivenost linija:  ${COMBINED_LINES}"
echo -e "${GREEN}Svi izvestaji su u folderu: $REPORTS_DIR${NC}"
