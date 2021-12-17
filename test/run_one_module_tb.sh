#!/bin/bash

MODULENAME="$1"

iverilog -g 2012 -s ${MODULENAME} -o bin/${MODULENAME}  ../rtl/*.v ../rtl/*/*.v ../modules_tb/*.v

./bin/${MODULENAME}
