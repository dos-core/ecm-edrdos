@echo off

:: Public Domain

call cfg.bat
set /e unixcwd=unix -w
lredir -f i: %unixcwd%/drdos
set unixcwd=
cd drbio
call link.bat
cd ..
cd drdos
call link.bat
cd ..
cd command
call link.bat
cd ..
