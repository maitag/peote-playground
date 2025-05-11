haxe serverCpp.hxml

@echo off
if not exist bin mkdir bin
@echo on

copy build\cpp\Haxemud.exe bin\haxemud.exe

@echo off
REM creates (clickable;) batch files for cpp server and client
if not exist bin\haxemudCpp.bat (
  echo haxemud.exe
  echo pause
) > bin\haxemudCpp.bat


if "%~1"=="" pause

@echo on