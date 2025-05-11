#!/bin/bash

haxe serverCpp.hxml

test -d "bin" || mkdir -p "bin"

cp build/cpp/Haxemud bin/haxemud
