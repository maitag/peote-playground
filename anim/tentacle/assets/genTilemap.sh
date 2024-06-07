# http://www.imagemagick.org/Usage/formats/#png_formats

###################
# extract pure RGBA
###################
magick montage \
 ./render/tentacle_normal_depth%04d.png[1-24] \
 -tile 8x -geometry 128x128 \
 -background none \
 -depth 8 \
 -define png:color-type=6 \
 -quality 00 \
 tentacle_normal_depth.png

magick montage \
 ./render/tentacle_uv_ao_alpha%04d.png[1-24] \
 -tile 8x -geometry 128x128 \
 -background none \
 -depth 8 \
 -define png:color-type=6 \
 -quality 00 \
 tentacle_uv_ao_alpha.png

