# CPU coursework 2021/2022

This repository contains code for the CPU coursework for the second-year EIE module Instruction Architectures and Compilers.

## Assembler
Addresses of all instructions assembled by the assembler are automatically increased bt offset of 0xBFC00000.

## Instructions

### ADDU - Add Unsigned Word

### ADDIU - Add Immediate Unsigned Word

### JR - Jump Register

### LW - Load Word

### SW - Store Word

Registers encoding: [DOC Imperial](https://www.doc.ic.ac.uk/lab/secondyear/spim/node10.html)

## Before submission check
- src/mipsregisterfile.v:30: warning: System task ($display) cannot be synthesized in an always_ff process. - remove all $display statements before the submission progress
- can the MIPS address offset be negative?

## Authors
- Michal Palic
- Vaclav Pavlicek
- Pablo Romo Gonzalez
- Arthika Sivathasan
- Henry Hausamann
- Yusuf Salim