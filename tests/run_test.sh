#!/bin/bash
set -e

# Compile (assuming running from repo root)
gprbuild -P aetherlink.gpr

# Run
./obj/main > tests/output.txt

# Verify Output
if grep -q "PASS: Data matches transmitted data" tests/output.txt && \
   grep -q "PASS: Packet rejected as expected" tests/output.txt; then
    echo "Test Passed!"
    cat tests/output.txt
    exit 0
else
    echo "Test Failed!"
    cat tests/output.txt
    exit 1
fi
