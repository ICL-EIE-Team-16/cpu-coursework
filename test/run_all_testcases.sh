#!/bin/bash
set -eou pipefail
SOURCE_DIRECTORY="$1"
INSTRUCTION_TO_TEST="$2"

# Use a wild-card to specifiy that every file with this pattern represents a testcase file
TESTCASES="./test/test-cases/*/*.asm.txt"

if [[ -n "$INSTRUCTION_TO_TEST" ]] ; then
  TESTCASES="./test/test-cases/$INSTRUCTION_TO_TEST-*/$INSTRUCTION_TO_TEST-*.asm.txt"
fi

VERBOSE="DISABLE" # in order to enable VERBOSE output from the script mode, this value has to be set to ENABLED

# Loop over every file matching the testcase pattern
for i in ${TESTCASES} ; do
    TESTNAME=$(basename ${i} .asm.txt)
    # Dispatch to the main test-case script
    ./test/run_one_testcase.sh ${SOURCE_DIRECTORY} ${TESTNAME} ${VERBOSE} "mips_cpu_bus_tb"
    # ./run_one_testcase.sh ${SOURCE_DIRECTORY} ${TESTNAME} ${VERBOSE} "mips_cpu_bus_memory_tb"
done