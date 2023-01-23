package;

import lime.app.Application;
import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Texture;
import peote.view.Element;
import peote.view.Color;

import utils.Loader;

class Bulby implements Element
{
	@sizeX @const public var w:Int=512;
	@sizeY @const public var h:Int=512;

	@texTile() public var tile:Int = 0;
	
	@posX @constStart(0) @constEnd(800) @anim("X","pingpong") @formula("xStart+(xEnd-w-xStart)*time0") public var x:Int;
	@posY @constStart(0) @constEnd(600) @anim("Y","pingpong") @formula("yStart+(yEnd-h-yStart)*time1*time1") public var y:Int;

	public function new(x:Int, y:Int, currTime:Float) {
		this.timeX(currTime, 10);
		this.timeY(currTime, 3);
	}

}

class Main extends Application
{	
	override function onWindowCreate():Void
	{		
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				
				var peoteView = new PeoteView(window);

				var display = new Display(0, 0, 800, 600, Color.BLACK);
				
				var buffer = new Buffer<Bulby>(1);
				var program = new Program(buffer);
		
				var frameSize = 64;

				Loader.image("assets/bulby_spritesheet.png", true, function(image:Image)
				{
					var texture = new Texture(image.width, image.height);
					// define texture tiles
					texture.tilesX = Std.int(image.width / frameSize);
					texture.tilesY = Std.int(image.height / frameSize);
					texture.setImage(image);
					
					program.addTexture(texture, "custom");
					program.snapToPixel(1); // for smooth animation

					peoteView.addDisplay(display);
					display.addProgram(program);
					
					buffer.addElement(new Bulby(0, 0, peoteView.time));
					
					peoteView.start();
				});				
				
			default:			
		}		
	}		

}
