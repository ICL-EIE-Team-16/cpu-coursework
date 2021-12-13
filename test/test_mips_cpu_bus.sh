#!/bin/bash

SOURCE_DIRECTORY="$1"
INSTRUCTION_TO_TEST="$2"

# Adds execution permission for scripts
chmod +x ./test/clean_all.sh ./test/build_utils.sh ./test/run_all_testcases.sh ./test/run_one_testcase.sh

# Cleans all files generated during the run of previous testing
set +e
./test/clean_all.sh
RESULT_CLEAN=$?
set -e

# Build MIPS utilities for converting instructions to hexadecimal numbers.
./test/build_utils.sh

# Checks if only single instruction should be tested or if all instructions should be tested
if [[ -z "$INSTRUCTION_TO_TEST" ]] ; then
  ./test/run_all_testcases.sh "$SOURCE_DIRECTORY" ""
else
  ./test/run_all_testcases.sh "$SOURCE_DIRECTORY" "$INSTRUCTION_TO_TEST"
fi
