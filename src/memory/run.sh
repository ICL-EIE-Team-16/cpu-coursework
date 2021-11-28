#!/bin/bash
N='
'

#The assumptions
#1) The name of the file without extension is the name of its module
#2) Testbenches contain "_tb" somewhere in their name
#3) There are no duplicate modules with identical names



shopt -s extglob
#Files found
FILES=$( ls *.v)

FILE_ARR=($FILES)

echo "Found these files:"

i=1
for element in "${FILE_ARR[@]}"
do
    echo "    [${i}] ${element}"
    ((i++))
done

#Benches found
BENCHES=$( ls *_tb*.v)

#Check if any benches are found
BENCH_ARR=($BENCHES)

BENCH_NUM="${#BENCH_ARR[@]}"

#Bench list empty
if [ $BENCH_NUM = 0 ]
then
    echo "No benches found, aborting. Make sure to name your benches *_tb.v"
    exit 1

#Only one bench found
elif [ $BENCH_NUM = 1 ]
then
  echo "Only one bench found inferred top level module"
  TLF=(${BENCH_ARR[0]})
#More benches found - user selection
else
  echo $BENCHES
  echo "Select desired testbench [1-${BENCH_NUM}], 'a' to run all:"
  i=1
  for element in "${BENCH_ARR[@]}"
  do
      echo "    [${i}] ${element}"
      ((i++))
  done

  #Top level file selection
  read FNUM

  all="FALSE"
  if [ $FNUM = "a" ]
  then
    TLF=("${BENCH_ARR[@]}")
  else
    ((FNUM--))
    TLF=(${BENCH_ARR[FNUM]})
  fi
fi


mkdir -p "${PWD}/build"

for BENCH in "${TLF[@]}"
do

    echo "$N Running icarus with $BENCH:"
    #echo "iverilog -Wall -g 2012 -s ${TLF%%.*} -o build/${BENCH%%.*} $FILES"


    iverilog -Wall -g 2012 -s ${BENCH%%.*} -o build/${BENCH%%.*} $FILES &&

    echo "$N Running simulation:" &&

    ./build/${BENCH%%.*} &&

    echo "$N Running GTK:" &&
    gtkwave waves.vcd

done
echo "done"


