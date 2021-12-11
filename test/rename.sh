#!/bin/bash

set -eou pipefail

TESTCASES="./test-inputs-legacy/0-assembly/*"

ASSEMBLY_REGEX="./test-inputs-legacy/0-assembly/([1-9]+)-([a-z]+)"

# Loop over every file matching the testcase pattern
for i in ${TESTCASES} ; do
    if [[ ${i} =~ $ASSEMBLY_REGEX ]]; then
        if [ ! -d "test-cases/${BASH_REMATCH[2]}-${BASH_REMATCH[1]}" ]
          then
            mkdir "test-cases/${BASH_REMATCH[2]}-${BASH_REMATCH[1]}"
          end
        fi

        # ASM_PATH="./test-inputs-legacy/0-assembly/${BASH_REMATCH[1]}-${BASH_REMATCH[2]}*"
        REF_V0_PATH="./test-inputs-legacy/4-reference/${BASH_REMATCH[1]}-${BASH_REMATCH[2]}*"

        # for x in ${ASM_PATH} ; do
          # if [ -f "$x" ]; then
            # cat ${x} > ./test-cases/${BASH_REMATCH[2]}-${BASH_REMATCH[1]}/${BASH_REMATCH[2]}-${BASH_REMATCH[1]}.asm.txt
          # fi
        # done

        for x in ${REF_V0_PATH} ; do
          echo "here: ${x}"
          if [ -f "$x" ]; then
            cat ${x} > ./test-cases/${BASH_REMATCH[2]}-${BASH_REMATCH[1]}/${BASH_REMATCH[2]}-${BASH_REMATCH[1]}-v0.ref
          fi
        done
    else
      echo "does not match"
    fi
done

# ./test-inputs-legacy/0-assembly/70-sltiu-false.asm.txt
# ./test-inputs-legacy/0-assembly/80-divu_lo.asm.txt
