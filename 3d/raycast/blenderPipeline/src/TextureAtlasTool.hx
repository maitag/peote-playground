package;

import lime.graphics.Image;
import peote.view.*;

class Elem implements Element
{
  @posX public var x:Int = 0;
  @posY public var y:Int = 0;
  @sizeX public var w:Int = 128;
  @sizeY public var h:Int = 128;
  var OPTIONS = { blend:true };
}

// generates a great TextureAtlas some random loaded images
class TextureAtlasTool {

	static var peoteView:PeoteView;
	static var display:Display;
	static var fbTexture:Texture;
	static var program:Program;
	static var buffer:Buffer<Elem>;
	static var tileElem:Elem;

	public static function generate(peoteView:PeoteView, width:Int, height:Int, tilesX:Int, tilesY:Int, imageLinks:Array<String>, bgColor = Color.BLACK):Texture {

		TextureAtlasTool.peoteView = peoteView;
		
		display = new Display(0, 0, width, height);
		
		buffer = new Buffer<Elem>(1);
		program = new Program(buffer);
		display.addProgram(program);

		tileElem = new Elem();
		tileElem.w = Std.int(width/tilesX);
		tileElem.h = Std.int(height/tilesY);

		buffer.addElement(tileElem);
		
		fbTexture = new Texture(width, height, 1, {tilesX:tilesX, tilesY:tilesY});
		
		fbTexture.setData(new TextureData(width, height, bgColor));
		fbTexture.clearOnRenderInto = false; // <- this is IMPORTANT to renderOVER :)

		peoteView.setFramebuffer(display, fbTexture);

		Load.imageArray(
			imageLinks,
			//, true, // <-- enable this to see the default load-debugger 
			function(index:Int, loaded:Int, size:Int) {
				// trace(' File number $index progress ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
			},
			function(loaded:Int, size:Int) {
				// trace(' Progress overall: ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
			},
			function(index:Int, image:Image) { // after every single image is loaded
				// trace('File number $index loaded completely.');
				
				var texture = Texture.fromData( image );
				texture.setSmooth(true,true,true);

				program.setTexture(texture);

				var x = index % tilesX;
				var y = Std.int(index/tilesX);
				
				tileElem.x = x * Std.int(width/tilesX);
				tileElem.y = y * Std.int(height/tilesY);

				buffer.updateElement(tileElem);

				trace('render tile $index into Texture at:', tileElem.x, tileElem.y);
				peoteView.renderToTexture(display);
				
			},
			function(images:Array<Image>) { // after all images is loaded
				trace(' --- all images loaded ---');

				fbTexture.setSmooth(true,true,true);
				
				/*
				var texture:Texture;

				for (y in 0...tilesY)
					for (x in 0...tilesX)
					{
						var index:Int = y*tilesX + x;
						if (index < images.length)
						{
							texture = Texture.fromData( images[index] );

							program.setTexture(texture);

							tileElem.x = x * Std.int(width/tilesX);
							tileElem.y = y * Std.int(height/tilesY);

							buffer.updateElement(tileElem);

							trace('render tile $index into Texture at:', tileElem.x, tileElem.y);
							peoteView.renderToTexture(display);
						}
					}
				*/

			}
		);

		return fbTexture;
	}


}