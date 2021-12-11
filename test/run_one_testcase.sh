#!/bin/bash
set -eou pipefail

SOURCE_DIRECTORY="$1"
TESTCASE="$2"
VERBOSE="$3"
BASE_TEST_BENCH="$4"

# Determine the name of the instruction

INSTRUCTION_REGEX="([a-z]+)"
INSTR_NAME=""

if [[ $TESTCASE =~ $INSTRUCTION_REGEX ]]; then
    INSTR_NAME="${BASH_REMATCH[1]}"
fi

# Redirect output to stder (&2) so that it seperate from genuine outputs
if [ "${VERBOSE}" = "ENABLE" ] ; then
   >&2 echo "Test MIPS CPU using test-case ${TESTCASE}"
   >&2 echo "  1 - Assembling input file"
fi

# Generate hex files from assembly
test/bin/assembler <test/test-cases/${TESTCASE}/${TESTCASE}.asm.txt > test/test-cases/${TESTCASE}/${TESTCASE}.hex.txt

if [ "${VERBOSE}" = "ENABLE" ] ; then
   >&2 echo "  2 - Compiling test-bench"
fi

# Compile a specific test bench for this specific test case.
# The -P command is used to modify the RAM_INIT_FILE parameter on the test-bench at compile-time

if [ "${VERBOSE}" = "ENABLE" ] ; then
  if [ -d "${SOURCE_DIRECTORY}/mips_cpu" ] ; then
    iverilog -g 2012 -Wall \
         -s "${BASE_TEST_BENCH}" \
         -P"${BASE_TEST_BENCH}".RAM_INIT_FILE=\"test/test-cases/${TESTCASE}/${TESTCASE}.hex.txt\" \
         -o test/test-cases/${TESTCASE}/${BASE_TEST_BENCH}_${TESTCASE} \
         ${SOURCE_DIRECTORY}/mips_cpu_*.v ${SOURCE_DIRECTORY}/mips_cpu/*.v test/testbenches/*.v
  else
    iverilog -g 2012 -Wall \
             -s "${BASE_TEST_BENCH}" \
             -P"${BASE_TEST_BENCH}".RAM_INIT_FILE=\"test/test-cases/${TESTCASE}/${TESTCASE}.hex.txt\" \
             -o test/test-cases/${TESTCASE}/${BASE_TEST_BENCH}_${TESTCASE} \
             ${SOURCE_DIRECTORY}/mips_cpu_*.v test/testbenches/*.v
  fi
else
  # silence the output from the command
  if [ -d "${SOURCE_DIRECTORY}/mips_cpu" ] ; then
      iverilog -g 2012 \
           -s "${BASE_TEST_BENCH}" \
           -P"${BASE_TEST_BENCH}".RAM_INIT_FILE=\"test/test-cases/${TESTCASE}/${TESTCASE}.hex.txt\" \
           -o test/test-cases/${TESTCASE}/${BASE_TEST_BENCH}_${TESTCASE} \
           ${SOURCE_DIRECTORY}/mips_cpu_*.v ${SOURCE_DIRECTORY}/mips_cpu/*.v test/testbenches/*.v > /dev/null
    else
      iverilog -g 2012 \
               -s "${BASE_TEST_BENCH}" \
               -P"${BASE_TEST_BENCH}".RAM_INIT_FILE=\"test/test-cases/${TESTCASE}/${TESTCASE}.hex.txt\" \
               -o test/test-cases/${TESTCASE}/${BASE_TEST_BENCH}_${TESTCASE} \
               ${SOURCE_DIRECTORY}/mips_cpu_*.v test/testbenches/*.v > /dev/null
    fi
fi


if [ "${VERBOSE}" = "ENABLE" ] ; then
   >&2 echo "  3 - Running test-bench"
fi

# Run test bench and redirect it's output to the output file
set +e
test/test-cases/${TESTCASE}/${BASE_TEST_BENCH}_${TESTCASE} > test/test-cases/${TESTCASE}/${BASE_TEST_BENCH}_${TESTCASE}.stdout
# Capture the exit code of the simulator in a variable
RESULT=$?
set -e

# Check whether the test bench returned a failure code, and immediately quit
if [[ "${RESULT}" -ne 0 ]] ; then
   echo "${TESTCASE} ${INSTR_NAME} Fail"
   exit
fi

if [ "${VERBOSE}" = "ENABLE" ] ; then
   >&2 echo "      Extracting result of OUT instructions"
fi
# This is the prefix for simulation output lines containing result of OUT instruction
REG_V0_PATTERN="REG v0: OUT: "
NOTHING=""

# Use "grep" to look only for lines containing REG_V0_PATTERN
set +e
grep "${REG_V0_PATTERN}" test/test-cases/${TESTCASE}/${BASE_TEST_BENCH}_${TESTCASE}.stdout > test/test-cases/${TESTCASE}/${BASE_TEST_BENCH}_${TESTCASE}.v0-out-lines
set -e
# Use "sed" to replace "Memory OUT: " with nothing
sed -e "s/${REG_V0_PATTERN}/${NOTHING}/g" test/test-cases/${TESTCASE}/${BASE_TEST_BENCH}_${TESTCASE}.v0-out-lines > test/test-cases/${TESTCASE}/${BASE_TEST_BENCH}_${TESTCASE}.out-v0

if [ "${VERBOSE}" = "ENABLE" ] ; then
   >&2 echo "  4 - Comparing output"
fi

# Note the -w to ignore whitespace
set +e
diff -w test/test-cases/${TESTCASE}/${TESTCASE}-v0.ref test/test-cases/${TESTCASE}/${BASE_TEST_BENCH}_${TESTCASE}.out-v0 > /dev/null
RESULT_V0=$?
set -e

# Based on whether differences were found, either pass or fail
if [[ "${RESULT_V0}" -ne 0 ]] ; then
   echo "${TESTCASE} ${INSTR_NAME} Fail"
else
   echo "${TESTCASE} ${INSTR_NAME} Pass"
fi