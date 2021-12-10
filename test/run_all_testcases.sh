#!/bin/bash
set -eou pipefail

# Use a wild-card to specifiy that every file with this pattern represents a testcase file
TESTCASES="./test-inputs/0-assembly/*.asm.txt"
VERBOSE="DISABLE" # in order to enable VERBOSE output from the script mode, this value has to be set to ENABLED

# Loop over every file matching the testcase pattern
for i in ${TESTCASES} ; do
    TESTNAME=$(basename ${i} .asm.txt)
    # Dispatch to the main test-case script
    ./run_one_testcase.sh ${TESTNAME} ${VERBOSE} "mips_cpu_bus_tb"
    # ./run_one_testcase.sh ${TESTNAME} ${VERBOSE} "mips_cpu_bus_memory_tb"
done