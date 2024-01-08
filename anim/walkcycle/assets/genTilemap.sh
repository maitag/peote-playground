# http://www.imagemagick.org/Usage/formats/#png_formats

###################
# extract pure RGBA
###################
magick montage \
 ./render/walk%04d.png[1-24] \
 -tile 8x -geometry 128x128 \
 -background none \
 -depth 8 \
 -define png:color-type=6 \
 -quality 00 \
 walk.png

