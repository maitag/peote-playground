package asset;

import lime.graphics.Image;

import peote.view.Load;
import peote.view.Texture;
import peote.view.TextureConfig;

class Util {
	public static function loadTextures(sheets:Array<Sheet>, postfix:String="", ?textureConfig:TextureConfig, ?onLoad:Array<Texture>->Void, debug = true):Array<Texture> {
		var textures = new Array<Texture>();
		var texFileNames = new Array<String>();

		for (sheet in sheets) {
			
			// TODO: extend blender-pipeline to support multiple files per sheet (and different img-filetypes whats using other textureFormat then!) 

			if (textureConfig == null) textureConfig = { powerOfTwo: false };
			textureConfig.tilesX = sheet.tilesX;
			textureConfig.tilesY = sheet.tilesY;
			
			textures.push(new Texture(sheet.width*sheet.tilesX, sheet.height*sheet.tilesY, 1, textureConfig));

			var name = ~/.png$/.replace(sheet.name, postfix+".png");

			texFileNames.push("assets/" + name);
		}

		Load.imageArray( texFileNames,
			debug, // debug
			function(index:Int, image:Image) { // after every single image is loaded
				// trace('File number $index loaded completely.');
				if (image.width != textures[index].width || image.height != textures[index].height)
					throw('Error int PipelineTools "loadTextures", image size does not fit');
				textures[index].setData(image);
			},
			function(images:Array<Image>) { // after all images is loaded
				// trace(' --- all images loaded ---');
				if (onLoad != null) onLoad(textures);
			}
		);
		
		return textures;
	}

	public static function loadTexture(sheet:Sheet, ?onLoad:Texture->Void, debug = true):Texture {
		var textureConfig:TextureConfig = {
			powerOfTwo: false,
			tilesX: sheet.tilesX,
			tilesY: sheet.tilesY
		};
		var texture = new Texture(sheet.width*sheet.tilesX, sheet.height*sheet.tilesY, 1, textureConfig);

		Load.image( "assets/" + sheet.name,
			debug, // debug
			function(image:Image) { // after image is loaded
				if (image.width != texture.width || image.height != texture.height)
					throw('Error int PipelineTools "loadTexture", image size does not fit');
				texture.setData(image);
				if (onLoad != null) onLoad(texture);
			}
		);
		
		return texture;
	}
}
