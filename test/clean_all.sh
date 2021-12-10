#!/bin/bash
set -eou pipefail

if ls test-inputs/1-hex/*.hex.txt 1> /dev/null 2>&1; then
    rm -rf test-inputs/1-hex/*.hex.txt
fi

if ls test-inputs/2-testcases/mips_cpu* 1> /dev/null 2>&1; then
    rm -rf test-inputs/2-testcases/mips_cpu*
fi

if ls test-inputs/3-output/mips_cpu* 1> /dev/null 2>&1; then
    rm -rf test-inputs/3-output/mips_cpu*
fi

