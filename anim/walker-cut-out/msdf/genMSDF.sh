#!/bin/bash

ZEROS="000"

for i in {1..96}
do

	if [[ $i -gt 9 ]]
	then
		ZEROS="00"
		if [[ $i -gt 99 ]]
		then
			ZEROS="0"
		fi
	fi

	echo $ZEROS$i.svg
	./msdfgen.exe -svg render/$ZEROS$i.svg -size 32 32 -o msdf/$ZEROS$i.png -scale 1.0

	
done



#./msdfgen.exe -svg render/0001.svg -size 32 32 -scale 1.0 -o msdf/0001.png

# ./msdfgen.exe -svg render/0001.svg -size 32 32 -o msdf/0001.png -scale 1.0 -testrender test.png 512 512 -printmetrics