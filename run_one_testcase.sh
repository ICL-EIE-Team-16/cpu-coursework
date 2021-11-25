#!/bin/bash
set -eou pipefail

TESTCASE="$1"

# Redirect output to stder (&2) so that it seperate from genuine outputs
>&2 echo "Test MIPS CPU using test-case ${TESTCASE}"
>&2 echo "  1 - Assembling input file"
bin/assembler <0-assembly/${TESTCASE}.asm.txt >1-binary/${TESTCASE}.hex.txt