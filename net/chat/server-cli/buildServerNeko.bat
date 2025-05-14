@echo off
if not exist src\net mkdir src\net
copy ..\src\net src\net
@echo on

haxe serverNeko.hxml

@echo off
if not exist bin mkdir bin
@echo on

copy build\neko\peotechatserver.n bin\peotechatserver.n

@echo off
REM creates (clickable;) batch files for neko server and client
if not exist bin\peotechatserverNeko.bat (
  echo neko peotechatserver.n
  echo pause
) > bin\peotechatserverNeko.bat



if "%~1"=="" pause

@echo on