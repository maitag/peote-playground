#!/bin/bash

haxe dedicatedServer.hxml

test -d "bin" || mkdir -p "bin"

cp build/neko/multipaintServer.n bin/multipaintServer.n

echo '#!/bin/bash\nneko multipaintServer.n "$@"' >bin/multipaintServer
chmod +x bin/multipaintServer

cp build/cpp/DedicatedServer bin/multipaintServer
