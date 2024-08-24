@ECHO off

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

if (%svardos%)==(0) goto :goodsvardos
if (%svardos%)==(1) goto :goodsvardos
echo Error: SvarDOS variable not set
goto failed
:goodsvardos

if (%svardossinglefile%)==(0) goto :goodsvardossinglefile
if (%svardossinglefile%)==(1) goto :goodsvardossinglefile
echo Error: SvarDOS singlefile variable not set
goto failed
:goodsvardossinglefile

REM Define local Caldera tools
SET LOCTOOLS=..\LTOOLS

IF NOT EXIST BIN\*.* MD BIN

copy ..\version.inc . /y
copy ..\svarver.mac . /y

REM *************************************
REM Build .ASM files first, get the obj's
REM *************************************

nasm -s -P nasm.mac -f obj initmsgs.nas -l bin/initmsgs.lst -o bin/initmsgs.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -s -P nasm.mac -f obj biosmsgs.nas -l bin/biosmsgs.lst -o bin/biosmsgs.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -DSVARDOS=%svardos% -DSINGLEFILE=%svardossinglefile% -DLDOS=1 -DSHORTVERSION=1 -DCOMPRESSED=%compressdrbio% -t -s -I ../lmacros/ -P nasm.mac -P nasmorg.mac -f obj init.nas -l bin/init.lst -o bin/init.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -s -P nasm.mac -f obj clock.nas -l bin/clock.lst -o bin/clock.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -s -P nasm.mac -f obj console.nas -l bin/console.lst -o bin/console.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -t -s -P nasm.mac -P nasmorg.mac -f obj disk.nas -l bin/disk.lst -o bin/disk.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -s -P nasm.mac -f obj serpar.nas -l bin/serpar.lst -o bin/serpar.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -s -P nasm.mac -f obj biosgrps.nas -l bin/biosgrps.lst -o bin/biosgrps.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -s -P nasm.mac -f obj stacks.nas -l bin/stacks.lst -o bin/stacks.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -s -P nasm.mac -f obj nlsfunc.nas -l bin/nlsfunc.lst -o bin/nlsfunc.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -DSVARDOS=%svardos% -DSINGLEFILE=%svardossinglefile% -t -s -P nasm.mac -f obj bdosldr.nas -l bin/bdosldr.lst -o bin/bdosldr.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -DSVARDOS=%svardos% -DSINGLEFILE=%svardossinglefile% -Dcompressdrdos=%compressdrdos% -t -s -P nasm.mac -f obj biosinit.nas -l bin/biosinit.lst -o bin/biosinit.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -s -P nasm.mac -f obj config.nas -l bin/config.lst -o bin/config.obj
IF ERRORLEVEL 1 GOTO FAILED
nasm -s -P nasm.mac -f obj genercfg.nas -l bin/genercfg.lst -o bin/genercfg.obj
IF ERRORLEVEL 1 GOTO FAILED

REM ***************************************************
REM Link the OBJ's and LIBR file to create the BIOS.EXE
REM and then use EXE2BIN to create the DRBIO.SYS file.
REM ***************************************************
warplink @wlbios.lnk
IF ERRORLEVEL 1 GOTO FAILED
echo.
x2b2 .\bin\bios.exe .\bin\drbio.tmp
IF ERRORLEVEL 1 GOTO FAILED
del .\bin\bios.exe
%LOCTOOLS%\round .\bin\drbio.tmp .\bin\drbio.bin 16
IF ERRORLEVEL 1 GOTO FAILED
del .\bin\drbio.tmp

if (%compressdrbio%)==(0) goto exit
if (%svardos%)==(1) if (%svardossinglefile%)==(1) goto exit
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
