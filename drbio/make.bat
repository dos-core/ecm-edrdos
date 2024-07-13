@ECHO off

SET JWASMEXE=C:\BIN\JWASM.EXE

REM 
REM YOU SHOULD NOT HAVE TO CHANGE ANYTHING BELOW THIS LINE.
REM 

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

%JWASMEXE% -c -Fl.\BIN\initmsgs.lst -Fo.\BIN\initmsgs initmsgs.asm
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -c -DLDOS -Fl.\BIN\biosmsgs.lst -Fo.\BIN\biosmsgs biosmsgs.asm
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -c -Fl.\BIN\init.lst -Fo.\BIN\init init.asm
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -c -Fl.\BIN\clock.lst -Fo.\BIN\clock clock.asm
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -c -Fl.\BIN\console.lst -Fo.\BIN\console console.asm
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -c -Fl.\BIN\disk.lst -Fo.\BIN\disk disk.asm
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
%JWASMEXE% -c -Fl.\BIN\biosinit.lst -Fo.\BIN\biosinit biosinit.asm
IF ERRORLEVEL 1 GOTO FAILED
%JWASMEXE% -c -Fl.\BIN\config.lst -Fo.\BIN\config config.asm
IF ERRORLEVEL 1 GOTO FAILED

REM ******************************************
REM Build the library so that we can link into
REM ******************************************
%LOCTOOLS%\rasm_sh %LOCTOOLS%\rasm86.exe . .\confstub.a86 .\BIN\confstub.o86 $sz /DDRDOS35=0 /DADDDRV=0
IF ERRORLEVEL 1 GOTO FAILED
%LOCTOOLS%\fixupp .\BIN\confstub.o86 .\BIN\confstub.obj RELOC > bin\confstub.rel
IF ERRORLEVEL 1 GOTO FAILED
%LOCTOOLS%\rasm_sh %LOCTOOLS%\rasm86.exe . .\bdosstub.a86 .\BIN\bdosstub.o86 $sz /DDRDOS35=0 /DADDDRV=0
IF ERRORLEVEL 1 GOTO FAILED
%LOCTOOLS%\fixupp .\BIN\bdosstub.o86 .\BIN\bdosstub.obj RELOC > bin\bdosstub.rel
IF ERRORLEVEL 1 GOTO FAILED

REM ******************************************
REM Build the .A86 files next, get the obj's
REM ******************************************
%LOCTOOLS%\rasm_sh %LOCTOOLS%\rasm86.exe . .\genercfg.a86 .\BIN\genercfg.o86 $sz /DDRDOS35=0 /DADDDRV=0
IF ERRORLEVEL 1 GOTO FAILED
%LOCTOOLS%\fixupp .\BIN\genercfg.o86 .\BIN\genercfg.obj RELOC > bin\genercfg.rel
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
:: %LOCTOOLS%\compbios .\bin\drbio.sys .\bin\drbio.sys
:: %LOCTOOLS%\compbios .\bin\drbio.bin .\bin\drbio.bin
:: IF ERRORLEVEL 1 GOTO FAILED
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
