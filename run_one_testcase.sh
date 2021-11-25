#!/bin/bash
set -eou pipefail

TESTCASE="$1"

# Redirect output to stder (&2) so that it seperate from genuine outputs
>&2 echo "Test MIPS CPU using test-case ${TESTCASE}"
>&2 echo "  1 - Assembling input file"
bin/assembler <test-inputs/0-assembly/${TESTCASE}.asm.txt >test-inputs/1-binary/${TESTCASE}.hex.txt

>&2 echo "  2 - Compiling test-bench"
# Compile a specific test bench for this specific test case.
# The -P command is used to modify the RAM_INIT_FILE parameter on the test-bench at compile-time
iverilog -g 2012 \
   -s MIPS_tb \
   -PMIPS_tb.RAM_INIT_FILE=\"test-inputs/1-binary/${TESTCASE}.hex.txt\" \
   -o test-inputs/2-testcases/MIPS_tb_${TESTCASE} \
   src/*.v testbenches/*.v
