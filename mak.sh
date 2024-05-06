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

build_name=edrdos build_pack_name=edrpack build_unpack_name=edrdos \
  ../kernwrap/mak.sh -Idrbio/bin/ -Idrdos/bin/
