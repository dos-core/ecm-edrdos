@ECHO off

SET JWASMEXE=C:\BIN\JWASM.EXE

REM 
REM YOU SHOULD NOT HAVE TO CHANGE ANYTHING BELOW THIS LINE.
REM 

if (%compressdrbio%)==(0) goto :goodbcomp
if (%compressdrbio%)==(1) goto :goodbcomp
echo Error: Compress DRBIO variable not set
goto failed
:goodbcomp

if (%compressdrdos%)==(0) goto :gooddcomp
if (%compressdrdos%)==(1) goto :gooddcomp
echo Error: Compress DRDOS variable not set
goto failed
:gooddcomp

REM Define local Caldera tools
SET LOCTOOLS=..\LTOOLS

IF NOT EXIST BIN\*.* MD BIN

REM Check if tools exist

ECHO Checking for %JWASMEXE%
if not exist %JWASMEXE% goto badtool

copy ..\version.inc . /y

REM *************************************
REM Build .ASM files first, get the obj's
REM *************************************

nasm -s -P nasm.mac -f obj initmsgs.nas -l bin/initmsgs.lst -o bin/initmsgs.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -DLDOS -DSHORTVERSION -s -P nasm.mac -f obj biosmsgs.nas -l bin/biosmsgs.lst -o bin/biosmsgs.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -DCOMPRESSED=%compressdrbio% -s -P nasm.mac -P nasmorg.mac -f obj init.nas -l bin/init.lst -o bin/init.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -s -P nasm.mac -f obj clock.nas -l bin/clock.lst -o bin/clock.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -s -P nasm.mac -f obj console.nas -l bin/console.lst -o bin/console.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -s -P nasm.mac -P nasmorg.mac -f obj disk.nas -l bin/disk.lst -o bin/disk.obj
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -c -Fl.\BIN\serpar.lst -Fo.\BIN\serpar serpar.asm
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -c -Fl.\BIN\biosgrps.lst -Fo.\BIN\biosgrps biosgrps.asm
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -c -Fl.\BIN\stacks.lst -Fo.\BIN\stacks stacks.asm
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -c -Fl.\BIN\nlsfunc.lst -Fo.\BIN\nlsfunc nlsfunc.asm
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -c -Fl.\BIN\bdosldr.lst -Fo.\BIN\bdosldr bdosldr.asm
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -Dcompressdrdos=%compressdrdos% -c -Fl.\BIN\biosinit.lst -Fo.\BIN\biosinit biosinit.asm
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -c -Fl.\BIN\config.lst -Fo.\BIN\config config.asm
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -c -Fl.\BIN\genercfg.lst -Fo.\BIN\genercfg genercfg.asm
IF ERRORLEVEL 1 GOTO FAILED

REM ***************************************************
REM Link the OBJ's and LIBR file to create the BIOS.EXE
REM and then use EXE2BIN to create the DRBIO.SYS file.
REM ***************************************************
warplink @wlbios.lnk
IF ERRORLEVEL 1 GOTO FAILED
echo.
:: x2b2 .\bin\bios.exe .\bin\drbio.sys
x2b2 .\bin\bios.exe .\bin\drbio.bin
IF ERRORLEVEL 1 GOTO FAILED
del .\bin\bios.exe

if (%compressdrbio%)==(0) goto exit
:: %LOCTOOLS%\compbios .\bin\drbio.sys .\bin\drbio.sys
%LOCTOOLS%\compbios .\bin\drbio.bin .\bin\drbio.bin
IF ERRORLEVEL 1 GOTO FAILED
goto exit

:failed
ECHO Error in Build!
goto exit

:badtool
ECHO Can't find that tool!

:exit
REM *********
REM CLEANUP
REM *********

SET LOCTOOLS=
