#!/bin/bash

set -eou pipefail

TESTCASES="./test-cases/*"

INSTRUCTION_REGEX="./test-cases/([a-z]+-[1-9])"

# Loop over every file matching the testcase pattern
for i in ${TESTCASES} ; do
    if [[ ${i} =~ $INSTRUCTION_REGEX ]]; then
        INSTR_PATH="./test-cases/${BASH_REMATCH[1]}/*-v0.ref"
        for i in ${INSTR_PATH} ; do
          if [ ${i} != "./test-cases/${BASH_REMATCH[1]}/${BASH_REMATCH[1]}-v0.ref" ]
          then
              #cat ${i} > ./test-cases/${BASH_REMATCH[1]}/${BASH_REMATCH[1]}-v0.ref
            rm -rf ${i}
          fi
        done

        INSTR_PATH="./test-cases/${BASH_REMATCH[1]}/*.asm.txt"
        for i in ${INSTR_PATH} ; do
          if [ ${i} != "./test-cases/${BASH_REMATCH[1]}/${BASH_REMATCH[1]}.asm.txt" ]
          then
            rm -rf ${i}
            # cat ${i} > ./test-cases/${BASH_REMATCH[1]}/${BASH_REMATCH[1]}.asm.txt
          fi
        done
    else
      echo "does not match"
    fi
done