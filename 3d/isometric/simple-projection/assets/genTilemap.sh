# http://www.imagemagick.org/Usage/formats/#png_formats

###################
# extract pure RGBA
###################
magick montage \
 ./render/tile%04d.png[1-16] \
 -tile 4x4 -geometry 48x48 \
 -background none \
 -depth 8 \
 -define png:color-type=6 \
 -quality 00 \
 tiles.png

