@ECHO off

SET OPT_S=

SET JWASMEXE=C:\BIN\JWASM.EXE -c -Zm -Zg
SET WATCOM=C:\WATCOM
SET WATCOMH=%WATCOM%\H
IF EXIST %WATCOM%\BINB\WCC.EXE SET WC=%WATCOM%\BINB\WCC.EXE
IF EXIST %WATCOM%\BINW\WCC.EXE SET WC=%WATCOM%\BINW\WCC.EXE

REM
REM YOU SHOULD NOT HAVE TO CHANGE ANYTHING BELOW THIS LINE.
REM 

REM Define local Caldera tools
SET LOCTOOLS=..\LTOOLS

IF NOT EXIST BIN\*.* MD BIN

REM Check if tools exist

ECHO Checking for %JWASMEXE%
if not exist %JWASMEXE% goto badtool
ECHO Checking for %WC%
if not exist %WC% goto badtool


ECHO /mx /w0 /as:1 /nd .\bin\cstart.obj+.\bin\com.obj+.\bin\csup.obj+> resp2
ECHO .\bin\dosif.obj+.\bin\comint.obj+.\bin\support.obj+>> resp2
ECHO .\bin\cmdlist.obj+.\bin\printf.obj+>> resp2
ECHO .\bin\message.obj+>> resp2
ECHO .\bin\batch.obj+.\bin\global.obj+.\bin\config.obj+>> resp2
ECHO .\bin\comcpy.obj+.\bin\crit.obj+>> resp2
ECHO .\bin\resident.obj>> resp2
ECHO .\bin\command.exe>> resp2
ECHO .\command.map>> resp2
ECHO %WATCOM%\LIB286\DOS\CLIBs+%WATCOM%\LIB286\MATH87s>> resp2
warplink @resp2;
IF ERRORLEVEL 1 GOTO FAILED
echo.


ECHO /w0 /as:1 /nd .\bin\helpstub.obj+> resp3
ECHO .\bin\txhelp.obj>> resp3
ECHO .\bin\txhelp.exe>> resp3
warplink @resp3;
IF ERRORLEVEL 1 GOTO FAILED
echo.

x2b2 .\bin\txhelp.exe .\bin\txhelp.bin
IF ERRORLEVEL 1 GOTO FAILED

copy /b .\bin\command.exe+.\bin\txhelp.bin .\bin\command.com
goto exit

:failed
ECHO Error in Build!
goto exit

:badtool
ECHO Can't find that tool!

:exit
REM **********************
REM CLEAN UP THE AREA
REM **********************

SET JWASMEXE=
SET WC=
SET WATCOMH=
SET LOCTOOLS=
