#!/bin/bash

set -eou pipefail

ASSEMBLER_MIPS_SRCS="utils/opcodes.h utils/registers.h utils/instruction-parse-config.h utils/utils.h"

echo "Building MIPS utils"
mkdir -p bin
g++ -o bin/assembler utils/assembler.cpp ${ASSEMBLER_MIPS_SRCS}
echo "  done"
