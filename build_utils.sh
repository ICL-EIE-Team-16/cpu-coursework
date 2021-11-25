#!/bin/bash

set -eou pipefail

MIPS_SRCS="utils/opcodes.h utils/registers.h"

echo "Building MIPS utils" > /dev/stderr
mkdir -p bin
g++ -o bin/assembler utils/assembler.cpp ${MIPS_SRCS}
echo "  done" > /dev/stderr
