magick convert \
 ./%05d.png[1-17] \
 -crop 490x224+268+392 +repage \
 ./crop%01d.jpg
