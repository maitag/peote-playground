haxe serverNeko.hxml

@echo off
if not exist bin mkdir bin
@echo on

copy build\neko\multipaintServer.n bin\multipaintServer.n

@echo off
REM creates (clickable;) batch files for neko server and client
if not exist bin\neko_multipaintServer.bat (
  echo neko multipaintServer.n
  echo pause
) > bin\neko_multipaintServer.bat



if "%~1"=="" pause

@echo on