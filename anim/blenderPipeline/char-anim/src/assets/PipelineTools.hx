package assets;

import lime.graphics.Image;
import peote.view.Load;
import peote.view.Texture;
import peote.view.TextureConfig;

// https://try.haxe.org/#A7D4f6Ec

class PipelineTools {
	public static function loadTextures(sheets:Array<Sheet>):Array<Texture> {
		var textures = new Array<Texture>();
		var texFileNames = new Array<String>();

		for (sheet in sheets) {
			var textureConfig:TextureConfig = {
				powerOfTwo: false,
				tilesX: sheet.tilesX,
				tilesY: sheet.tilesY
			};
			textures.push(new Texture(sheet.width*sheet.tilesX, sheet.height*sheet.tilesY, 1, textureConfig));
			texFileNames.push("assets/" + sheet.name);
		}

		Load.imageArray( texFileNames,
			true, // debug
			function(index:Int, image:Image) { // after every single image is loaded
				trace('File number $index loaded completely.');
				if (image.width != textures[index].width || image.height != textures[index].height)
					throw('Error int PipelineTools "loadTextures", image size does not fit');
				textures[index].setData(image);
			},
			function(images:Array<Image>) { // after all images is loaded
				trace(' --- all images loaded ---');
			}
		);
		
		return textures;
	}
}

@:structInit @:publicFields class Sheet {
	var name:String;
	var width:Int;
	var height:Int;
	var gap:Int;
	var tilesX:Int;
	var tilesY:Int;
	public function new(n:String, w:Int, h:Int, g:Int, tx:Int, ty:Int) {
		name = n;
		width = w;
		height = h;
		gap = g;
		tilesX = tx;
		tilesY = ty;
	}
}

@:structInit @:publicFields class Anim {
	var start:Int;
	var end:Int;
	public inline function new(s:Int, e:Int) {
		start = s;
		end = e;
	}
}
