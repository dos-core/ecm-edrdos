@echo off

:: Public Domain

call cfg.bat
cd drbio
call make.bat
cd ..
cd drdos
call make.bat
cd ..
cd command
call make.bat
cd ..
