#! /bin/bash

# Public Domain

rm -f edrdos.bin
rm -f edrdos.lz
rm -f edrdos.pak
rm -f edrdos.com
rm -f edrdos.sys
rm -f edrpack.com
rm -f edrpack.sys

(cd ltools; ./mak.sh)

if [ "$1" == "onlypl" ]
then
  shift
else
  [ -z "$DOSEMU" ] && DOSEMU=dosemu
  "$DOSEMU" -dumb -td -kt -K "$PWD" -E "mak.bat"
fi

nasm version.asm -I ../lmacros/ -o version.com

nasm ../ldosboot/drkernpl.asm -I ../lmacros/ \
  -I drbio/bin/ -I drdos/bin/ -o edrdos.bin
lzip -9vvfkc edrdos.bin > edrdos.lz
nasm ../inicomp/inicomp.asm -I ../inicomp/ -I ../lmacros/ \
  -D_PAYLOAD_FILE='"edrdos.lz"' -o edrdos.pak -D_LZD
nasm ../ldosboot/iniload.asm -I ../ldosboot/ -I ../lmacros/ -I ../scanptab/ \
  -D_PAYLOAD_FILE='"edrdos.pak"' -D_INILOAD_SIGNATURE='"DR"' -o edrpack.com \
  -D_SECOND_PAYLOAD_EXE -D_SECOND_PAYLOAD_FILE='"version.com"' \
  -D_SECOND_PAYLOAD_EXE_IP=256 \
  "$@"
nasm ../ldosboot/iniload.asm -I ../ldosboot/ -I ../lmacros/ -I ../scanptab/ \
  -D_PAYLOAD_FILE='"edrdos.bin"' -D_INILOAD_SIGNATURE='"DR"' -o edrdos.com \
  -D_SECOND_PAYLOAD_EXE -D_SECOND_PAYLOAD_FILE='"version.com"' \
  -D_SECOND_PAYLOAD_EXE_IP=256 \
  "$@"
nasm ../ldosboot/drload.asm -I ../lmacros/ \
  -D_PAYLOAD_FILE='"edrdos.pak"' -o edrpack.sys "$@"
nasm ../ldosboot/drload.asm -I ../lmacros/ \
  -D_PAYLOAD_FILE='"edrdos.bin"' -o edrdos.sys "$@"
