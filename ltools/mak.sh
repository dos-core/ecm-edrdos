#! /bin/bash

ia16-elf-gcc -Wall -mcmodel=tiny -Os fixupp.c -o fixupp.exe "$@"
ia16-elf-gcc -Wall -mcmodel=tiny -Os round.c -o round.exe "$@"
ia16-elf-gcc -Wall -mcmodel=small -Os compbios.c -o compbios.exe -li86 "$@"
ia16-elf-gcc -Wall -mcmodel=small -Os compbdos.c -o compbdos.exe -li86 "$@"
