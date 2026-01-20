#!/bin/bash
set -e

# Compile Main
gprbuild -P aetherlink.gpr

# Compile Test Overflow
gnatmake tests/test_overflow.adb -Isrc -D obj -o obj/test_overflow

# Run Main Simulation
echo "--- Running Main Simulation ---"
./obj/main > tests/output.txt
if grep -q "VERIFICATION PASSED" tests/output.txt; then
    echo "Main Simulation Passed!"
else
    echo "Main Simulation Failed!"
    cat tests/output.txt
    exit 1
fi

# Run Overflow Test
echo "--- Running Overflow Test ---"
./obj/test_overflow > tests/overflow_output.txt
if grep -q "\[PASS\]" tests/overflow_output.txt; then
    echo "Overflow Test Passed!"
    rm tests/overflow_output.txt
    exit 0
else
    echo "Overflow Test Failed!"
    cat tests/overflow_output.txt
    exit 1
fi
