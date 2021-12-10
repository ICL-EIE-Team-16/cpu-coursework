# CPU coursework 2021/2022

This repository contains code for the CPU coursework for the second-year EIE module Instruction Architectures and Compilers.

## Directories structure

- `modules_tb` - test benches for particular submodules of the CPU
- `rtl` - folder that contains Verilog source files for the CPU
  - `mips_cpu_bus.v` - main Verilog CPU module that interconnects all submodules
  - `mips_cpu/*.v` - Verilog files for submodules
- `test` - contains files for testing
  - `bin` - contains binary files that are needed to run the testing environment
  - `logs` - contains log files from separate module test benches
  - `inputs` - data for test cases
    - `0-assembly` - testing assembly programs 
    - `1-hex` - testing assembled hexadecimal files that are loaded to the memory starting from address `0xBCF00000` 
    - `2-testcases` - compiled Verilog programs  
    - `3-output` - logs from executed Verilog programs
    - `4-reference` - reference files that are used to compare outputs from programs
  - `testbenches` - template test bench files that are used as a source for all assembly programs testing
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
All bash scripts in the `test` folder assume that they will be executed in the `test` folder.
- need to add permissions to all bash scripts in the file

## Assembler
In order to speed ut testing, MIPS assembler was implemented in C++. This assembler takes as an input assembly file with MIPS instructions. As an output, it then generates hex files that are loaded to RAM memory using file as a parameter in Verilog. The assembler was developed with a use of test driven development. Unit tests can be found in `test/utils/test`. The test cases are written in Google Test and the whole C++ environment was set up using CMake.
Due to the fact that MIPS programs start at `0xBFC00000`, all data address are automatically aligned by offset of `0xBFC00000`.
Currently, the assembler does not implement noop instruction.
Regular expressions for instructions validation are not that perfect.

### Todo
- Add clean up to testing scripts.
- Test option to jump backwards.
- Add negative offsets to memory instructions.
- Need more programs - that check problems such as negative offsets and correct sign extensions.

Registers encoding: [DOC Imperial](https://www.doc.ic.ac.uk/lab/secondyear/spim/node10.html)

## Possible problems
- problematic output from simple memory and problems with timing of components
- will our test benches run on DTs CPU when all our source files will be in `mips_cpu` folder?
- How will the test bench will be run? Will it be run from the root folder or from the test folder? - ask during mentors meeting

## Before submission check
- src/mipsregisterfile.v:30: warning: System task ($display) cannot be synthesized in an always_ff process. - remove all $display statements before the submission progress
- can the MIPS address offset be negative?
- how the rounding in division should work?
- How will DTs test cases be run? Is he going connect our CPU to his memory?

## Authors
- Michal Palic
- Vaclav Pavlicek
- Pablo Romo Gonzalez
- Arthika Sivathasan
- Henry Hausamann
- Yusuf Salim