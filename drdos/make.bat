@ECHO off

SET JWASMEXE=C:\BIN\JWASM.EXE

REM 
REM YOU SHOULD NOT HAVE TO CHANGE ANYTHING BELOW THIS LINE.
REM 

if (%compressdrdos%)==(0) goto :gooddcomp
if (%compressdrdos%)==(1) goto :gooddcomp
echo Error: Compress DRDOS variable not set
goto failed
:gooddcomp

REM Define local Caldera tools
SET LOCTOOLS=..\LTOOLS

IF NOT EXIST BIN\*.* MD BIN

ECHO Checking for %JWASMEXE%
if not exist %JWASMEXE% goto badtool

copy ..\version.inc . /y

nasm -s -P nasm.mac -P nasmorg.mac -f obj header.nas -l bin/header.lst -o bin/header.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj pcmif.nas -l bin/pcmif.lst -o bin/pcmif.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -DDELWATCH -s -P nasm.mac -f obj buffers.nas -l bin/buffers.lst -o bin/buffers.obj
IF ERRORLEVEL 1 GOTO FAILED

nasm -DDELWATCH -DJOIN -s -P nasm.mac -f obj bdevio.nas -l bin/bdevio.lst -o bin/bdevio.obj
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -DDELWATCH -DKANJI -DJOIN -c -Fl.\BIN\redir.lst -Fo.\BIN\redir redir.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Fl.\BIN\lfn.lst -Fo.\BIN\lfn lfn.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Fl.\BIN\cdevio.lst -Fo.\BIN\cdevio cdevio.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -DDELWATCH -c -Fl.\BIN\dirs.lst -Fo.\BIN\dirs dirs.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Fl.\BIN\cio.lst -Fo.\BIN\cio cio.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Fl.\BIN\support.lst -Fo.\BIN\support support.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -DDELWATCH -c -Fl.\BIN\disk.lst -Fo.\BIN\disk disk.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Fl.\BIN\dosmem.lst -Fo.\BIN\dosmem dosmem.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Fl.\BIN\cmdline.lst -Fo.\BIN\cmdline cmdline.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Fl.\BIN\dos7.lst -Fo.\BIN\dos7 dos7.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Fl.\BIN\error.lst -Fo.\BIN\error error.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Fl.\BIN\fcbs.lst -Fo.\BIN\fcbs fcbs.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -DPASSWORD -DJOIN -c -Fl.\BIN\fioctl.lst -Fo.\BIN\fioctl fioctl.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -DPASSWORD -c -Fl.\BIN\ioctl.lst -Fo.\BIN\ioctl ioctl.asm
IF ERRORLEVEL 1 GOTO FAILED

nasm -s -P nasm.mac -f obj history.nas -l bin/history.lst -o bin/history.obj
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -DDELWATCH -c -Fl.\BIN\int2f.lst -Fo.\BIN\int2f int2f.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Fl.\BIN\network.lst -Fo.\BIN\network network.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Fl.\BIN\misc.lst -Fo.\BIN\misc misc.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Fl.\BIN\process.lst -Fo.\BIN\process process.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -DDELWATCH -DKANJI -DPASSWORD -DJOIN -DUNDELETE -c -Fl.\BIN\fdos.lst -Fo.\BIN\fdos fdos.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Zm -Zg -Fl.\BIN\dosgrps.lst -Fo.\BIN\dosgrps dosgrps.asm
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

%JWASMEXE% -bin -Fo.\BIN\country.sys country.asm
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
