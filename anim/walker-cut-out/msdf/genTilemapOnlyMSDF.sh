# http://www.imagemagick.org/Usage/formats/#png_formats

###################
# extract pure RGBA
###################
magick montage \
 ./msdf/%04d.png[1-96] \
 -tile 16x -geometry 32x32 \
 -background none \
 -depth 8 \
 -define png:color-type=6 \
 -quality 75 \
 walkOnlyMSDF.png

