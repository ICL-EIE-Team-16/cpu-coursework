#!/bin/bash
set -eou pipefail

if ls test/test-cases/*/*.hex.txt 1> /dev/null 2>&1; then
    rm -rf test/test-cases/*/*.hex.txt
fi

if ls test/test-cases/*/mips_cpu* 1> /dev/null 2>&1; then
    rm -rf test/test-cases/*/mips_cpu*
fi

