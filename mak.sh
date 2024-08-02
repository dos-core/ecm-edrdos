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
gcc -O3 ltools/fixupp.c -o ltools/fixupp

if [ "$1" == "onlypl" ]
then
  shift
else
  [ -z "$DOSEMU" ] && DOSEMU=dosemu
  "$DOSEMU" -dumb -td -kt -K "$PWD" -E "mak.bat"
fi

notracelist=0
if [[ "$1" == "notracelist" ]]
then
  shift
  notracelist=1
fi
nobiotracelist=0
if [[ "$1" == "nobiotracelist" ]]
then
  shift
  nobiotracelist=1
fi
nodostracelist=0
if [[ "$1" == "nodostracelist" ]]
then
  shift
  nodostracelist=1
fi

build_name=edrdos build_pack_name=edrpack build_unpack_name=edrdos \
  ../kernwrap/mak.sh -Idrbio/bin/ -Idrdos/bin/

if ! (( notracelist )) && ! (( nobiotracelist ))
then
  echo === Creating BIO trace listing
  bash -c '
    for file
      do ./ltools/fixupp drbio/"$file".obj /dev/null reloc > drbio/"$file".rel
    done' scriptlet $(
    grep JWASM drbio/make.bat |
    grep -Eio '\-Fo[^ ]+' |
    sed -re 's/-Fo//g;s/\\/\//g;s/\/BIN\//\/bin\//g'
    ) &&
  convlist.pl drbio/bin/bios.map $(
    grep JWASM drbio/make.bat |
    grep -Eio '\-Fo[^ ]+' |
    sed -re 's/-Fo//g;s/\\/\//g;s/\/BIN\//\/bin\//g;s/^\.\//drbio\//g;s/$/\.rel/g'
  ) $(
    cat drbio/wlbios.lnk |
    grep -Eoi '.\\bin\\[0-9a-zA-Z]+\.obj' |
    sed -re 's/\.\\bin\\/drbio\/bin\//g;s/\.obj/\.lst/g'
  ) > drbio.tls
fi

if ! (( notracelist )) && ! (( nodostracelist ))
then
  echo === Creating DOS trace listing
  bash -c '
    for file
      do [ "${file}" != ./bin/country.sys ] &&
        ./ltools/fixupp drdos/"$file".obj /dev/null reloc > drdos/"$file".rel
      true
    done' scriptlet $(
    grep JWASM drdos/make.bat |
    grep -Eio '\-Fo[^ ]+' |
    sed -re 's/-Fo//g;s/\\/\//g;s/\/BIN\//\/bin\//g'
    ) &&
  convlist.pl drdos/bin/drdos.map $(
    grep JWASM drdos/make.bat |
    grep -v country.sys |
    grep -Eio '\-Fo[^ ]+' |
    sed -re 's/-Fo//g;s/\\/\//g;s/\/BIN\//\/bin\//g;s/^\.\//drdos\//g;s/$/\.rel/g'
  ) $(
    cat drdos/wldrdos.lnk |
    grep -Eoi '.\\bin\\[0-9a-zA-Z]+\.obj' |
    sed -re 's/\.\\bin\\/drdos\/bin\//g;s/\.obj/\.lst/g'
  ) > drdos.tls
fi

