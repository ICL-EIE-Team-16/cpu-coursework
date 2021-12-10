#!/bin/bash

# Cleans all files generated during the run of previous testing
./clean_all.sh

# Build MIPS utilities for converting instructions to hexadecimal numbers.
./build_utils.sh

# Run all test-cases
./run_all_testcases.sh