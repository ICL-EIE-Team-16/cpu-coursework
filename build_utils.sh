#!/bin/bash

set -eou pipefail

ASSEMBLER_MIPS_SRCS="utils/opcodes.h utils/registers.h utils/instruction-parse-config.h utils/utils.h"
CONVERTER_SRCS="utils/utils.h"

echo "Building MIPS utils"
mkdir -p bin
g++ -o bin/assembler utils/assembler.cpp ${ASSEMBLER_MIPS_SRCS}
g++ -o bin/csvhexconvert utils/csvhexconvert.cpp ${CONVERTER_SRCS}
echo "  done"
