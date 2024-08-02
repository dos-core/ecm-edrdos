@echo off

:: Public Domain

call cfg.bat
cd drbio
call link.bat
cd ..
cd drdos
call link.bat
cd ..
cd command
call link.bat
cd ..
