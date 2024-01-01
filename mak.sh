#! /bin/bash

# Public Domain

rm -f edrdos.bin
rm -f edrdos.lz
rm -f edrdos.pak
rm -f edrdos.com
rm -f edrdos.sys
rm -f edrpack.com
rm -f edrpack.sys

if [ "$1" == "onlypl" ]
then
  shift
else
  [ -z "$DOSEMU" ] && DOSEMU=dosemu
  "$DOSEMU" -dumb -td -kt -K "$PWD" -E "mak.bat"
fi

nasm ../ldosboot/drkernpl.asm -I ../lmacros/ -I drbio/bin/ -I drdos/bin/ -o edrdos.bin
lzip -9vvfkc edrdos.bin > edrdos.lz
nasm ../inicomp/inicomp.asm -I ../inicomp/ -I ../lmacros/ -D_PAYLOAD_FILE='"edrdos.lz"' -o edrdos.pak -D_LZD
# nasm ../ldosboot/iniload.asm -I ../lmacros/ -I ../scanptab/ -D_PAYLOAD_FILE='"edrdos.pak"' -D_INILOAD_SIGNATURE='"DR"' -o edrpack.com "$@"
# nasm ../ldosboot/iniload.asm -I ../lmacros/ -I ../scanptab/ -D_PAYLOAD_FILE='"edrdos.bin"' -D_INILOAD_SIGNATURE='"DR"' -o edrdos.com "$@"
nasm ../ldosboot/drload.asm -I ../lmacros/ -D_PAYLOAD_FILE='"edrdos.pak"' -o edrpack.sys "$@"
nasm ../ldosboot/drload.asm -I ../lmacros/ -D_PAYLOAD_FILE='"edrdos.bin"' -o edrdos.sys "$@"
