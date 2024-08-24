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
