# CPU coursework 2021/2022

This repository contains code for the CPU coursework for the second-year EIE module Instruction Architectures and Compilers.

## Overall design

The following diagram shows the overall design of the developed CPU.

![CPU block diagram](images/cpu-block-diagram.png?raw=true "CPU block diagram")

## Directories structure

- `modules_tb` - test benches for particular submodules of the CPU
- `modules_tb` - test benches for particular submodules of the CPU pipelined version of CPU
- `rtl` - folder that contains Verilog source files for the CPU
  - `mips_cpu_bus.v` - main Verilog CPU module that interconnects all submodules
  - `mips_cpu/*.v` - Verilog files for submodules
- `rtl_pipelined` - folder that contains Verilog source files for the pipelined version of the CPU that fully supports only main memory
  - `mips_cpu_bus.v` - main Verilog CPU module that interconnects all submodules
  - `mips_cpu/*.v` - Verilog files for submodules
- `test` - contains files for testing
  - `bin` - contains binary files that are needed to run the testing environment
  - `logs` - contains log files from separate module test benches
  - `testbenches` - template test bench files that are used as a source for all assembly programs testing
    - `memories` - folder with memories used by test benches
  - `utils` - assembler files
    - `test` - unit tests for assembler
  - `build_utils.sh` - builds utility files needed
  - `clean_all.sh` - cleans all files from previous testing
  - `run_all_testcases.sh` - runs all testcases
  - `run_one_module_tb.sh` - runs exactly one test bench, parameter: name of the test bench
  - `run_one_testcase.sh` - runs exactly one testcase, parameters: testcase name, verbose enabled/disabled, base test bench name
  - `test_mips_cpu_bus.sh` - runs all test cases for the submission
- `CMakeLists.txt` - CMake file for setting up CLion unit testing environment

## Testing
All bash scripts in the `test` folder assume that they will be executed in the root folder of the project.

Following command runs all testcases for ADDIU instruction on the non-pipelined CPU:

````
./test/test_mips_cpu_bus.sh rtl addiu
````

To run all test cases on the non-pipelined CPU enter following command:

````
./test/test_mips_cpu_bus.sh rtl addiu
````

## Assembler
In order to speed ut testing, MIPS assembler was implemented in C++. This assembler takes as an input assembly file with MIPS instructions. As an output, it then generates hex files that are loaded to RAM memory using file as a parameter in Verilog. The assembler was developed with a use of test driven development. Unit tests can be found in `test/utils/test`. The test cases are written in Google Test and the whole C++ environment was set up using CMake.
Due to the fact that MIPS programs start at `0xBFC00000`, all data address are automatically aligned by offset of `0xBFC00000`. The nop instruction in the assembler can be written as `NOP`.

## Authors
- Michal Palič
- Vaclav Pavlíček
- Pablo Romo Gonzalez
- Arthika Sivathasan
- Henry Hausamann
- Yusuf Salim