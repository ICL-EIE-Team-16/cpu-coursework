#!/bin/bash
set -eou pipefail
SOURCE_DIRECTORY="$1"
INSTRUCTION_TO_TEST="$2"

# Use a wild-card to specifiy that every file with this pattern represents a testcase file
TESTCASES="./test/test-cases/*/*.asm.txt"

# Check if only one instruction should be tested
if [[ -n "$INSTRUCTION_TO_TEST" ]] ; then
  TESTCASES="./test/test-cases/$INSTRUCTION_TO_TEST-*/$INSTRUCTION_TO_TEST-*.asm.txt"
fi

# Controls verbose mode of the script, in order to enable VERBOSE output from the script mode, this value has to be set to ENABLED
VERBOSE="DISABLE"

# Loop over every file matching the testcase pattern
for i in ${TESTCASES} ; do
    TESTNAME=$(basename ${i} .asm.txt)
    set +e
    ./test/run_one_testcase.sh ${SOURCE_DIRECTORY} ${TESTNAME} ${VERBOSE} "mips_cpu_bus_tb"
    set -e

    # set +e
    # ./test/run_one_testcase.sh ${SOURCE_DIRECTORY} ${TESTNAME} ${VERBOSE} "mips_cpu_bus_memory_tb"
    # set -e
done