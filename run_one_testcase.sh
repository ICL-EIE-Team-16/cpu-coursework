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

>&2 echo "  3 - Running test-bench"
# Run the simulator, and capture all output to a file
# Use +e to disable automatic script failure if the command fails, as
# it is possible the simulation might go wrong.
set +e
test-inputs/2-testcases/MIPS_tb_${TESTCASE} > test-inputs/3-output/MIPS_tb_${TESTCASE}.stdout
# Capture the exit code of the simulator in a variable
RESULT=$?
set -e

# Check whether the simulator returned a failure code, and immediately quit
if [[ "${RESULT}" -ne 0 ]] ; then
   echo "${TESTCASE}, FAIL - SIMULATION"
   exit
fi

>&2 echo "      Extracting result of OUT instructions"
# This is the prefix for simulation output lines containing result of OUT instruction
RAM_PATTERN="Memory OUT: "
REG_PATTERN="REG : INFO : "
NOTHING=""
# Use "grep" to look only for lines containing RAM_PATTERN
set +e
grep "${RAM_PATTERN}" test-inputs/3-output/MIPS_tb_${TESTCASE}.stdout > test-inputs/3-output/MIPS_tb_${TESTCASE}.ram-out-lines
set -e
# Use "sed" to replace "Memory OUT: " with nothing
sed -e "s/${RAM_PATTERN}/${NOTHING}/g" test-inputs/3-output/MIPS_tb_${TESTCASE}.ram-out-lines > test-inputs/3-output/MIPS_tb_${TESTCASE}.out-ram

# Use "grep" to look only for lines containing REG_PATTERN
set +e
grep "${REG_PATTERN}" test-inputs/3-output/MIPS_tb_${TESTCASE}.stdout > test-inputs/3-output/MIPS_tb_${TESTCASE}.reg-out-lines
set -e
# Use "sed" to replace "Memory OUT: " with nothing
sed -e "s/${REG_PATTERN}/${NOTHING}/g" test-inputs/3-output/MIPS_tb_${TESTCASE}.reg-out-lines > test-inputs/3-output/MIPS_tb_${TESTCASE}.out-reg

>&2 echo "  4 - Comparing output"
# Note the -w to ignore whitespace
set +e
diff -w test-inputs/4-reference/${TESTCASE}.ref test-inputs/3-output/MIPS_tb_${TESTCASE}.out-ram
RESULT_RAM=$?
set -e

# Note the -w to ignore whitespace
set +e
diff -w test-inputs/4-reference/${TESTCASE}-reg.ref.csv test-inputs/3-output/MIPS_tb_${TESTCASE}.out-reg
RESULT_REG=$?
set -e

# Based on whether differences were found, either pass or fail
if [[ "${RESULT_RAM}" -ne 0 ]] ; then
   echo "      ${TESTCASE}, FAIL - RAM"
else
   echo "      ${TESTCASE}, PASS - RAM"
fi

# Based on whether differences were found, either pass or fail
if [[ "${RESULT_REG}" -ne 0 ]] ; then
   echo "      ${TESTCASE}, FAIL - REG"
else
   echo "      ${TESTCASE}, PASS - REG"
fi