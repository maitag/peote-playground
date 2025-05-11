haxe serverNeko.hxml

@echo off
if not exist bin mkdir bin
@echo on

copy build\neko\haxemud.n bin\haxemud.n

@echo off
REM creates (clickable;) batch files for neko server and client
if not exist bin\haxemudNeko.bat (
  echo neko haxemud.n
  echo pause
) > bin\haxemudNeko.bat



if "%~1"=="" pause

@echo on