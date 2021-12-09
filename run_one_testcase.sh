#!/bin/bash
set -eou pipefail

TESTCASE="$1"
VERBOSE="$2"
BASE_TEST_BENCH="$3"

# Redirect output to stder (&2) so that it seperate from genuine outputs
if [ "${VERBOSE}" = "ENABLE" ] ; then
   >&2 echo "Test MIPS CPU using test-case ${TESTCASE}"
   >&2 echo "  1 - Assembling input file"
fi
bin/assembler <test-inputs/0-assembly/${TESTCASE}.asm.txt >test-inputs/1-binary/${TESTCASE}.hex.txt

if [ "${VERBOSE}" = "ENABLE" ] ; then
   >&2 echo "  2 - Compiling test-bench"
fi
# Compile a specific test bench for this specific test case.
# The -P command is used to modify the RAM_INIT_FILE parameter on the test-bench at compile-time
# TODO: add -Wall  to see all the warnings

if [ "${VERBOSE}" = "ENABLE" ] ; then
  iverilog -g 2012 -Wall \
     -s "${BASE_TEST_BENCH}" \
     -P"${BASE_TEST_BENCH}".RAM_INIT_FILE=\"test-inputs/1-binary/${TESTCASE}.hex.txt\" \
     -o test-inputs/2-testcases/"${BASE_TEST_BENCH}"_${TESTCASE} \
     src/*.v testbenches/*.v
else
  # silence the output from the command
  iverilog -g 2012 \
       -s ${BASE_TEST_BENCH} \
       -P${BASE_TEST_BENCH}.RAM_INIT_FILE=\"test-inputs/1-binary/${TESTCASE}.hex.txt\" \
       -o test-inputs/2-testcases/${BASE_TEST_BENCH}_${TESTCASE} \
       src/*.v testbenches/*.v > /dev/null
fi


if [ "${VERBOSE}" = "ENABLE" ] ; then
   >&2 echo "  3 - Running test-bench"
fi
# Run the simulator, and capture all output to a file
# Use +e to disable automatic script failure if the command fails, as
# it is possible the simulation might go wrong.
set +e
test-inputs/2-testcases/${BASE_TEST_BENCH}_${TESTCASE} > test-inputs/3-output/${BASE_TEST_BENCH}_${TESTCASE}.stdout
# Capture the exit code of the simulator in a variable
RESULT=$?
set -e

# Check whether the simulator returned a failure code, and immediately quit
if [[ "${RESULT}" -ne 0 ]] ; then
   echo "${TESTCASE}, ${BASE_TEST_BENCH}, FAIL - SIMULATION"
   exit
fi

if [ "${VERBOSE}" = "ENABLE" ] ; then
   >&2 echo "      Extracting result of OUT instructions"
fi
# This is the prefix for simulation output lines containing result of OUT instruction
RAM_PATTERN="Memory OUT: "
REG_PATTERN="REGFile : OUT: "
REG_V0_PATTERN="REG v0: OUT: "
NOTHING=""
# Use "grep" to look only for lines containing RAM_PATTERN
set +e
grep "${RAM_PATTERN}" test-inputs/3-output/${BASE_TEST_BENCH}_${TESTCASE}.stdout > test-inputs/3-output/${BASE_TEST_BENCH}_${TESTCASE}.ram-out-lines
set -e
# Use "sed" to replace "Memory OUT: " with nothing
sed -e "s/${RAM_PATTERN}/${NOTHING}/g" test-inputs/3-output/${BASE_TEST_BENCH}_${TESTCASE}.ram-out-lines > test-inputs/3-output/${BASE_TEST_BENCH}_${TESTCASE}.out-ram

# Use "grep" to look only for lines containing REG_PATTERN
# set +e
# grep "${REG_PATTERN}" test-inputs/3-output/MIPS_tb_${TESTCASE}.stdout > test-inputs/3-output/MIPS_tb_${TESTCASE}.reg-out-lines
# set -e
# Use "sed" to replace "Memory OUT: " with nothing
#sed -e "s/${REG_PATTERN}/${NOTHING}/g" test-inputs/3-output/MIPS_tb_${TESTCASE}.reg-out-lines > test-inputs/3-output/MIPS_tb_${TESTCASE}.out-reg.csv

# Use "grep" to look only for lines containing REG_PATTERN
set +e
grep "${REG_V0_PATTERN}" test-inputs/3-output/${BASE_TEST_BENCH}_${TESTCASE}.stdout > test-inputs/3-output/${BASE_TEST_BENCH}_${TESTCASE}.v0-out-lines
set -e
# Use "sed" to replace "Memory OUT: " with nothing
sed -e "s/${REG_V0_PATTERN}/${NOTHING}/g" test-inputs/3-output/${BASE_TEST_BENCH}_${TESTCASE}.v0-out-lines > test-inputs/3-output/${BASE_TEST_BENCH}_${TESTCASE}.out-v0

if [ "${VERBOSE}" = "ENABLE" ] ; then
   >&2 echo "  4 - Comparing output"
fi
# Note the -w to ignore whitespace - RAM outputs comparison
# set +e
# diff -w test-inputs/4-reference/${TESTCASE}.ref test-inputs/3-output/MIPS_tb_${TESTCASE}.out-ram
# RESULT_RAM=$?
# set -e

# Note the -w to ignore whitespace
# set +e
# tail -n +1 test-inputs/3-output/MIPS_tb_${TESTCASE}.out-reg.csv > test-inputs/3-output/MIPS_tb_${TESTCASE}.out-reg-content.csv
# tail -n +1 test-inputs/4-reference/${TESTCASE}-reg.ref.csv > test-inputs/4-reference/${TESTCASE}-reg-content.ref.csv
# bin/csvhexconvert <test-inputs/4-reference/${TESTCASE}-reg-content.ref.csv >test-inputs/4-reference/${TESTCASE}-reg-content-converted.ref.csv
# diff -w test-inputs/4-reference/${TESTCASE}-reg-content-converted.ref.csv test-inputs/3-output/MIPS_tb_${TESTCASE}.out-reg-content.csv
# RESULT_REG=$?
# set -e

# Note the -w to ignore whitespace
set +e
diff -w test-inputs/4-reference/${TESTCASE}-v0.ref test-inputs/3-output/${BASE_TEST_BENCH}_${TESTCASE}.out-v0
RESULT_V0=$?
set -e

# Based on whether differences were found, either pass or fail - RAM comparison
# if [[ "${RESULT_RAM}" -ne 0 ]] ; then
#   echo "      ${TESTCASE}, FAIL - RAM"
# else
#   echo "      ${TESTCASE}, PASS - RAM"
# fi

# Based on whether differences were found, either pass or fail
# if [[ "${RESULT_REG}" -ne 0 ]] ; then
#     echo "      ${TESTCASE}, FAIL - REG"
# else
#    echo "      ${TESTCASE}, PASS - REG"
# fi

# Based on whether differences were found, either pass or fail
if [[ "${RESULT_V0}" -ne 0 ]] ; then
   echo "${TESTCASE}, ${BASE_TEST_BENCH}, FAIL - V0"
else
   echo "${TESTCASE}, ${BASE_TEST_BENCH}, PASS - V0"
fi