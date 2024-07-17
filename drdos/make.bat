@ECHO off

SET JWASMEXE=C:\BIN\JWASM.EXE

REM 
REM YOU SHOULD NOT HAVE TO CHANGE ANYTHING BELOW THIS LINE.
REM 

REM Define local Caldera tools
SET LOCTOOLS=..\LTOOLS

IF NOT EXIST BIN\*.* MD BIN

ECHO Checking for %JWASMEXE%
if not exist %JWASMEXE% goto badtool

copy ..\version.inc . /y

%JWASMEXE% -c -Fl.\BIN\header.lst -Fo.\BIN\header header.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Fl.\BIN\pcmif.lst -Fo.\BIN\pcmif pcmif.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -DDELWATCH -c -Fl.\BIN\buffers.lst -Fo.\BIN\buffers buffers.asm
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -DDELWATCH -DJOIN -c -Fl.\BIN\bdevio.lst -Fo.\BIN\bdevio bdevio.asm
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


REM ******************************************
REM Build the .A86 files next, get the obj's
REM ******************************************

%LOCTOOLS%\rasm_sh %LOCTOOLS%\rasm86.exe . .\fdos.a86 .\bin\fdos.o86 $sz /DDELWATCH /DKANJI /DDOS5 /DPASSWORD /DJOIN /DUNDELETE /Dshortversion
IF ERRORLEVEL 1 GOTO FAILED

%LOCTOOLS%\rasm_sh %LOCTOOLS%\rasm86.exe . .\ioctl.a86 .\bin\ioctl.o86 $sz /DPASSWORD /DDOS5
IF ERRORLEVEL 1 GOTO FAILED

%LOCTOOLS%\rasm_sh %LOCTOOLS%\rasm86.exe . .\misc.a86 .\bin\misc.o86 $sz /DDOS5
IF ERRORLEVEL 1 GOTO FAILED

%LOCTOOLS%\rasm_sh %LOCTOOLS%\rasm86.exe . .\process.a86 .\bin\process.o86 $sz /DDOS5
IF ERRORLEVEL 1 GOTO FAILED

%LOCTOOLS%\rasm_sh %LOCTOOLS%\rasm86.exe . .\network.a86 .\bin\network.o86
IF ERRORLEVEL 1 GOTO FAILED

%LOCTOOLS%\rasm_sh %LOCTOOLS%\rasm86.exe . .\int2f.a86 .\bin\int2f.o86 $sz /DDOS5 /DDELWATCH
IF ERRORLEVEL 1 GOTO FAILED

%LOCTOOLS%\rasm_sh %LOCTOOLS%\rasm86.exe . .\history.a86 .\bin\history.o86
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -c -Zm -Zg -Fl.\BIN\dosgrps.lst -Fo.\BIN\dosgrps dosgrps.asm
IF ERRORLEVEL 1 GOTO FAILED

for %f in (fdos) do %LOCTOOLS%\fixupp bin\%f.o86 bin\%f.obj RELOC > bin\%f.rel
for %f in (ioctl) do %LOCTOOLS%\fixupp bin\%f.o86 bin\%f.obj RELOC > bin\%f.rel
for %f in (misc) do %LOCTOOLS%\fixupp bin\%f.o86 bin\%f.obj RELOC > bin\%f.rel
for %f in (process network int2f history) do %LOCTOOLS%\fixupp bin\%f.o86 bin\%f.obj RELOC > bin\%f.rel

warplink @wldrdos.lnk
IF ERRORLEVEL 1 GOTO FAILED
echo.
x2b2 .\bin\drdos.exe .\bin\drdos.bin
IF ERRORLEVEL 1 GOTO FAILED
del .\bin\drdos.exe
IF ERRORLEVEL 1 GOTO FAILED
%LOCTOOLS%\round .\bin\drdos.bin .\bin\drdos.pag 128
IF ERRORLEVEL 1 GOTO FAILED
%LOCTOOLS%\compbdos .\BIN\drdos.pag .\BIN\drdos.sys
IF ERRORLEVEL 1 GOTO FAILED

%JWASMEXE% -bin -Fo=bin\country.sys country.asm
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
