package;

import lime.app.Application;
import lime.graphics.Image;

import peote.view.*;
import utils.Loader;

class SemmiBucket implements Element
{
	@sizeX @const public var w:Int=512;
	@sizeY @const public var h:Int=512;

	@texTile() public var tile:Int = 0;
	
	@posX @constStart(0) @constEnd(800) @anim("X","pingpong") @formula("xStart+(xEnd-w-xStart)*time0+w/2.0") public var x:Int;
	@posY @constStart(0) @constEnd(600) @anim("Y","pingpong") @formula("yStart+(yEnd-h-yStart)*time1*time1+h/2.0") public var y:Int;

	@rotation @const @formula("time0 * 389.0 ") public var r:Float;
	
	@pivotX @const @formula("w/2.0") public var px:Int;
	@pivotY @const @formula("h/2.0") public var py:Int;
	
	public function new(x:Int, y:Int, currTime:Float) {
		this.timeX(currTime, 10);
		this.timeY(currTime, 3);
	}

}

class Mudu extends Application
{
	var buffer:Buffer<SemmiBucket>;
	var mudu:SemmiBucket;
	
	override function onWindowCreate():Void
	{		
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				
				var peoteView = new PeoteView(window);

				var display = new Display(0, 0, 800, 600, 0xd9d8caff);
				
				buffer = new Buffer<SemmiBucket>(1);
				var program = new Program(buffer);
		
				var frameSize = 64;

				Loader.image("assets/mudu.png", true, function(image:Image)
				{
					var texture = new Texture(image.width, image.height);
					texture.setData(image);
					
					program.addTexture(texture, "custom");
					program.snapToPixel(1); // for smooth animation
					

					peoteView.addDisplay(display);
					display.addProgram(program);

					mudu = new SemmiBucket(0, 0, peoteView.time);
					buffer.addElement(mudu);
					
					peoteView.start();
				});				
				
			default:			
		}		
	}		
	
}
