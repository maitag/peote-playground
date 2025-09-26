# http://www.imagemagick.org/Usage/formats/#png_formats

###################
# extract pure RGBA
###################
magick montage \
 ./test/normal_depth%04d.png[1-16] \
 -tile 4x -geometry 32x32 \
 -background none \
 -depth 8 \
 -define png:color-type=6 \
 -quality 00 \
 test_normal_depth.png

magick montage \
 ./test/uv_ao_alpha%04d.png[1-16] \
 -tile 4x -geometry 32x32 \
 -background none \
 -depth 8 \
 -define png:color-type=6 \
 -quality 00 \
 test_uv_ao_alpha.png

