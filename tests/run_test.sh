#!/bin/bash
set -e

# Compile
gprbuild -P AetherLink/aetherlink.gpr

# Run
./AetherLink/obj/main > AetherLink/tests/output.txt

# Verify Output
if grep -q "VERIFICATION PASSED" AetherLink/tests/output.txt; then
    echo "Test Passed!"
    cat AetherLink/tests/output.txt
    exit 0
else
    echo "Test Failed!"
    cat AetherLink/tests/output.txt
    exit 1
fi
