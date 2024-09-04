@ECHO off

REM 
REM YOU SHOULD NOT HAVE TO CHANGE ANYTHING BELOW THIS LINE.
REM 

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

nasm -s -P nasm.mac -P nasmorg.mac -f obj header.nas -l bin/header.lst -o bin/header.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj pcmif.nas -l bin/pcmif.lst -o bin/pcmif.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -DDELWATCH -s -P nasm.mac -f obj buffers.nas -l bin/buffers.lst -o bin/buffers.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -DDELWATCH -DJOIN -s -P nasm.mac -f obj bdevio.nas -l bin/bdevio.lst -o bin/bdevio.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -DDELWATCH -DKANJI -DJOIN -s -P nasm.mac -f obj redir.nas -l bin/redir.lst -o bin/redir.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj lfn.nas -l bin/lfn.lst -o bin/lfn.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj cdevio.nas -l bin/cdevio.lst -o bin/cdevio.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -DDELWATCH -s -P nasm.mac -f obj dirs.nas -l bin/dirs.lst -o bin/dirs.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj cio.nas -l bin/cio.lst -o bin/cio.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj support.nas -l bin/support.lst -o bin/support.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -DDELWATCH -s -P nasm.mac -f obj disk.nas -l bin/disk.lst -o bin/disk.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj dosmem.nas -l bin/dosmem.lst -o bin/dosmem.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj cmdline.nas -l bin/cmdline.lst -o bin/cmdline.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj dos7.nas -l bin/dos7.lst -o bin/dos7.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj error.nas -l bin/error.lst -o bin/error.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj fcbs.nas -l bin/fcbs.lst -o bin/fcbs.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -DPASSWORD -DJOIN -s -P nasm.mac -f obj fioctl.nas -l bin/fioctl.lst -o bin/fioctl.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -DPASSWORD -s -P nasm.mac -f obj ioctl.nas -l bin/ioctl.lst -o bin/ioctl.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj history.nas -l bin/history.lst -o bin/history.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -DDELWATCH -s -P nasm.mac -f obj int2f.nas -l bin/int2f.lst -o bin/int2f.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj network.nas -l bin/network.lst -o bin/network.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -DSVARDOS=%svardos% -s -P nasm.mac -f obj misc.nas -l bin/misc.lst -o bin/misc.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj process.nas -l bin/process.lst -o bin/process.obj
IF ERRORLEVEL 1 GOTO FAILED

echo. > fdoscmd.mac
echo.%%define DELWATCH >> fdoscmd.mac
echo.%%define KANJI >> fdoscmd.mac
echo.%%define PASSWORD >> fdoscmd.mac
echo.%%define JOIN >> fdoscmd.mac
echo.%%define UNDELETE >> fdoscmd.mac
echo.%%define SHORTVERSION >> fdoscmd.mac

nasm -P fdoscmd.mac -s -P nasm.mac -f obj fdos.nas -l bin/fdos.lst -o bin/fdos.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj dosgrps.nas -l bin/dosgrps.lst -o bin/dosgrps.obj
IF ERRORLEVEL 1 GOTO FAILED


warplink @wldrdos.lnk
IF ERRORLEVEL 1 GOTO FAILED
echo.
x2b2 .\bin\drdos.exe .\bin\drdos.bin
IF ERRORLEVEL 1 GOTO FAILED
del .\bin\drdos.exe
IF ERRORLEVEL 1 GOTO FAILED
%LOCTOOLS%\round .\bin\drdos.bin .\bin\drdos.pag 128
IF ERRORLEVEL 1 GOTO FAILED

if (%compressdrdos%)==(0) goto :uncompressed
%LOCTOOLS%\compbdos .\BIN\drdos.pag .\BIN\drdos.sys
IF ERRORLEVEL 1 GOTO FAILED
goto :compressed

:uncompressed
%LOCTOOLS%\compbdos .\BIN\drdos.pag .\BIN\drdos.sys uncompressed
IF ERRORLEVEL 1 GOTO FAILED
:compressed

nasm -f bin country.nas -o bin/country.sys
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
