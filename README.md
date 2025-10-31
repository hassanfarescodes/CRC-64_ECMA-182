# CRC-64 ECMA-182

A simple NASM x86-64 implementation of the CRC-64 ECMA-182 checksum algorithm.  
This program reads a file, computes its CRC-64 checksum, and prints the result to stdout.

---

## Requirements
- Linux x86-64 system
- NASM assembler
- GNU linker (`ld`)

---

## Build
Assemble and link the program using the provided Makefile:

$ >> make

---

## Run

$ >> ./build/crc \<filename\>

---

## Test

$ >> ./build/crc test.txt

CRC: 6107472560464622295
