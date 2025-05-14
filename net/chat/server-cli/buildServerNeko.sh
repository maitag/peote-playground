#!/bin/bash

cp -r ../src/net src/

haxe serverNeko.hxml

test -d "bin" || mkdir -p "bin"

cp build/neko/peotechatserver.n bin/peotechatserver.n

echo '#!/bin/bash\nneko peotechatserver.n "$@"' >bin/peotechatserver
chmod +x bin/peotechatserver

