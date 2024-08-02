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
