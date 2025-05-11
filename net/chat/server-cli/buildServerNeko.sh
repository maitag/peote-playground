#!/bin/bash

haxe serverNeko.hxml

test -d "bin" || mkdir -p "bin"

cp build/neko/haxemud.n bin/haxemud.n

echo '#!/bin/bash\nneko haxemud.n "$@"' >bin/haxemud
chmod +x bin/haxemud

