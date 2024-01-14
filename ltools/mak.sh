#! /bin/bash

ia16-elf-gcc -Wall -mcmodel=tiny -Os fixupp.c -o fixupp.exe "$@"
ia16-elf-gcc -Wall -mcmodel=tiny -Os round.c -o round.exe "$@"
