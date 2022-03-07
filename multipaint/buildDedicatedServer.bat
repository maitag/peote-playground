haxe dedicatedServer.hxml

@echo off
if not exist bin mkdir bin
@echo on

copy build\neko\multipaintServer.n bin\multipaintServer.n

@echo off
REM creates (clickable;) batch files for neko server and client
if not exist bin\neko_multipaintServer.bat (
  echo neko multipaintServer.n -s 1 -v
  echo pause
) > bin\neko_multipaintServer.bat


copy build\cpp\DedicatedServer.exe bin\multipaintServer.exe

@echo off
REM creates (clickable;) batch files for cpp server and client
if not exist bin\multipaintServer.bat (
  echo multipaintServer.exe -s 1 -v
  echo pause
) > bin\multipaintServer.bat


if "%~1"=="" pause

@echo on