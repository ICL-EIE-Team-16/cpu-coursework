#!/bin/bash
# Adds execution permission for scripts
chmod +x clean_all.sh build_utils.sh run_all_testcases.sh run_one_testcase.sh

# Cleans all files generated during the run of previous testing
./clean_all.sh

# Build MIPS utilities for converting instructions to hexadecimal numbers.
./build_utils.sh

# Run all test-cases
./run_all_testcases.sh