#!/bin/bash

set -eou pipefail

TESTCASES="./test-inputs-legacy/0-assembly/*"

ASSEMBLY_REGEX="./test-inputs-legacy/0-assembly/([1-9]+)-([a-z]+)"

# Loop over every file matching the testcase pattern
for i in ${TESTCASES} ; do
    echo ${i}
    if [[ ${i} =~ $ASSEMBLY_REGEX ]]; then
        echo "new dir - ./test-cases/${BASH_REMATCH[2]}-${BASH_REMATCH[1]}"
        mkdir "./test-cases/${BASH_REMATCH[2]}-${BASH_REMATCH[1]}"
        ASM_PATH="./test-inputs-legacy/0-assembly/${BASH_REMATCH[1]}-${BASH_REMATCH[2]}*/*.asm.txt"
        REF_V0_PATH="./test-inputs-legacy/4-reference/${BASH_REMATCH[1]}-${BASH_REMATCH[2]}*/*-v0.ref"
        for i in ${ASM_PATH} ; do
          if [ -f "$i" ]; then
            cat ${i} > ./test-cases/${BASH_REMATCH[2]}-${BASH_REMATCH[1]}/${BASH_REMATCH[2]}-${BASH_REMATCH[1]}.asm.txt
          fi
        done

        for i in ${REF_V0_PATH} ; do
          if [ -f "$i" ]; then
            cat ${i} > ./test-cases/${BASH_REMATCH[2]}-${BASH_REMATCH[1]}/${BASH_REMATCH[2]}-${BASH_REMATCH[1]}-v0.ref
          fi
        done
    else
      echo "does not match"
    fi
done

./test-inputs-legacy/0-assembly/70-sltiu-false.asm.txt
./test-inputs-legacy/0-assembly/80-divu_lo.asm.txt
