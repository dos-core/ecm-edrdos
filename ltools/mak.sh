#! /bin/bash

ia16-elf-gcc -Wall -mcmodel=tiny -Os fixupp.c -o fixupp.exe "$@"
