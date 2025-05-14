haxe serverCpp.hxml

@echo off
if not exist bin mkdir bin
@echo on

copy build\cpp\PeoteChatServer.exe bin\peotechatserver.exe

@echo off
REM creates (clickable;) batch files for cpp server and client
if not exist bin\peotechatserverCpp.bat (
  echo peotechatserver.exe
  echo pause
) > bin\peotechatserverCpp.bat


if "%~1"=="" pause

@echo on