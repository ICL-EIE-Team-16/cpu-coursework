#!/bin/bash

set -eou pipefail

MIPS_SRCS="utils/opcodes.h utils/registers.h"

echo "Building MIPS utils"
mkdir -p bin
g++ -o bin/assembler utils/assembler.cpp ${MIPS_SRCS}
echo "  done"
