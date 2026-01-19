#!/bin/bash
set -e

# Compile
gprbuild -P aetherlink.gpr

# Run
./obj/main > tests/output.txt

# Verify Output
if grep -q "Data integrity verified" tests/output.txt; then
    echo "Test Passed!"
    cat tests/output.txt
    exit 0
else
    echo "Test Failed!"
    cat tests/output.txt
    exit 1
fi
