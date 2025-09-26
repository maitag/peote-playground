# http://www.imagemagick.org/Usage/formats/#png_formats

###################
# extract pure RGBA
###################
magick montage \
 ${path_normal_depth}${file_normal_depth}%04d.png[1-${endFrame}] \
 -tile ${tilesX}x -geometry ${width}x${height} \
 -background none \
 -depth 8 \
 -define png:color-type=6 \
 -quality 00 \
 ${output_file_normal_depth}.png

magick montage \
 ${path_uv_ao_alpha}${file_uv_ao_alpha}%04d.png[1-${endFrame}] \
 -tile ${tilesX}x -geometry ${width}x${height} \
 -background none \
 -depth 8 \
 -define png:color-type=6 \
 -quality 00 \
 ${output_file_uv_ao_alpha}.png

