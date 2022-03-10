haxe serverCpp.hxml

@echo off
if not exist bin mkdir bin
@echo on


copy build\cpp\DedicatedServer.exe bin\multipaintServer.exe

@echo off
REM creates (clickable;) batch files for cpp server and client
if not exist bin\multipaintServer.bat (
  echo multipaintServer.exe
  echo pause
) > bin\multipaintServer.bat


if "%~1"=="" pause

@echo on