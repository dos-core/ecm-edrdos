@echo off

:: Public Domain

call c:\autowat.bat
set /e unixcwd=unix -w
lredir -f i: %unixcwd%/drdos
set unixcwd=
cd command
call make.bat
cd ..
