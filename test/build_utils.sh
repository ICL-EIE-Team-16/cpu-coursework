#!/bin/bash

set -eou pipefail

ASSEMBLER_MIPS_SRCS="test/utils/opcodes.h test/utils/registers.h test/utils/instruction-parse-config.h test/utils/utils.h"

echo "Building MIPS utils"
mkdir -p bin
g++ -o test/bin/assembler test/utils/assembler.cpp ${ASSEMBLER_MIPS_SRCS}
echo "  done"
