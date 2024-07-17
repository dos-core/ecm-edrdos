@echo off

:: Public Domain

call cfg.bat
set /e unixcwd=unix -w
lredir -f i: %unixcwd%/drdos
set unixcwd=
cd drdos
call make.bat
cd ..
