#!/bin/bash
set -eou pipefail

if ls test/test-cases/*/*.hex.txt 1> /dev/null 2>&1; then
    rm -rf test/test-cases/*/*.hex.txt
fi

if ls test/test-cases/*/*.vcd 1> /dev/null 2>&1; then
    rm -rf test/test-cases/*/*.vcd
fi

if ls test/test-cases/*/*-mips_bus_* 1> /dev/null 2>&1; then
    rm -rf test/test-cases/*/*-mips_bus_*
fi

if ls test/test-cases/*/mips_bus_* 1> /dev/null 2>&1; then
    rm -rf test/test-cases/*/mips_bus_*
fi
