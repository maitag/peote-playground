#!/bin/bash

cp -r ../src/net src/

haxe serverCpp.hxml

test -d "bin" || mkdir -p "bin"

cp build/cpp/PeoteChatServer bin/peotechatserver
