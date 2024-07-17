@echo off

:: Public Domain

call c:\autowat.bat
set /e unixcwd=unix -w
lredir -f i: %unixcwd%/drdos
set unixcwd=
cd drdos
call make.bat
cd ..
