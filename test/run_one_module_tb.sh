#!/bin/bash

MODULENAME="mips_cpu_bus_integration_tb"

iverilog -g 2012 -s ${MODULENAME} -o bin/${MODULENAME}  ../src/*.v ../src/*/*.v ../modules_tb/*.v

set +e
bin/${MODULENAME} > logs/${MODULENAME}.stdout
RESULT=$?
set -e

if [[ "${RESULT}" -ne 0 ]] ; then
   echo "${MODULENAME}, FAIL"
   exit
else
   echo "${MODULENAME}, PASS"
   exit
fi