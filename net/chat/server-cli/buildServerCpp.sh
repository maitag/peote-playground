#!/bin/bash

haxe serverCpp.hxml

test -d "bin" || mkdir -p "bin"

cp build/cpp/PeoteChatServer bin/peotechatserver
