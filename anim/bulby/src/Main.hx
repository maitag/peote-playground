package;

import lime.app.Application;
import lime.graphics.Image;

import peote.view.*;

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
	var buffer:Buffer<Bulby>;
	var bulby:Bulby;

	var secondsRemaining:Float = 0;
	var secondsDuration:Float = 0.5;
	var isReady:Bool = false;
	
	override function onWindowCreate():Void
	{		
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				
				var peoteView = new PeoteView(window);

				var display = new Display(0, 0, 800, 600, Color.BLACK);
				
				buffer = new Buffer<Bulby>(1);
				var program = new Program(buffer);
		
				var frameSize = 64;

				Load.image("assets/bulby_spritesheet.png", true, function(image:Image)
				{
					var texture = new Texture(image.width, image.height);
					// define texture tiles
					texture.tilesX = Std.int(image.width / frameSize);
					texture.tilesY = Std.int(image.height / frameSize);
					texture.setData(image);
					
					program.addTexture(texture, "custom");
					program.snapToPixel(1); // for smooth animation

					peoteView.addDisplay(display);
					display.addProgram(program);

					bulby = new Bulby(0, 0, peoteView.time);
					buffer.addElement(bulby);
					
					peoteView.start();
					isReady = true;
				});				
				
			default:			
		}		
	}		
	
	override function update(deltaTime:Int) {
		super.update(deltaTime);
		if(!isReady) return;

		if(secondsRemaining <= 0){
			secondsRemaining = secondsDuration;
			var randomTileIndex = Math.floor(Math.random() * 5);
			bulby.tile = randomTileIndex;
			buffer.updateElement(bulby);
		}
		secondsRemaining -= (deltaTime / 1000);
	}
}
