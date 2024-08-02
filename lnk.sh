#! /bin/bash

# Public Domain

[ -z "$DOSEMU" ] && DOSEMU=dosemu
"$DOSEMU" -dumb -td -kt -K "$PWD" -E "lnk.bat"

./mak.sh onlypl "$@"
