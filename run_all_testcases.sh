#!/bin/bash
set -eou pipefail

# Use a wild-card to specifiy that every file with this pattern represents a testcase file
TESTCASES="0-assembly/*.asm.txt"

# Loop over every file matching the testcase pattern
for i in ${TESTCASES} ; do
    TESTNAME=$(basename ${i} .asm.txt)
    # Dispatch to the main test-case script
    ./run_one_testcase.sh ${TESTNAME}
done