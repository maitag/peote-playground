package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.*;

import pi_xy.Pixelimage;
import pi_xy.Pixelimage.ImageType;




class Elem implements Element
{
	@posX public var x:Int;
	@posY public var y:Int;
	
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	public function new(x:Int=0, y:Int=0, w:Int=100, h:Int=100)
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}
}



class Main extends Application
{	
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window)
	{	

		// create a new vision-image with a gold background
		// var image = new Pixelimage(512, 512, ImageType.BYTES_INT);
		var image = new Pixelimage(512, 512);

		
		// draw something inside
		for (y in 0...128) {
			for (x in 0...256) {
				image.setPixel(x, y, 0xffFFFF00); // ARGB ?
				// image.setPixel(x, y, Color.YELLOW);
			}	
		}
		var Violet      = 0xFF9400D3;
		var Indigo      = 0xFF4b0082;
		var Blue        = 0xFF0000FF;
		var Green       = 0xFF00ff00;
		var Yellow      = 0xFFFFFF00;
		var Orange      = 0xFFFF7F00;
		var Red         = 0xFFFF0000;
		var scale       = 10;
		// image.gradientShape.triangle( 100, 100, 0xf0ffcf00, 300, 220, 0xf000cfFF, 120, 300, 0xf0cF00FF );
		image.transparent = true;
		var colors = [ Violet, Indigo, Blue, Green, Yellow, Orange, Red ];
		var vertColor = colors[0]; 
		for( x in 0...70*scale ){
			 vertColor = colors[ Math.floor( (x/scale) / 10 ) ];
			 for( y in 0...768-70-45 ) image.setARGB( x, y, vertColor );
		}
		image.gradientShape.triangle( 100, 100, 0xf0ffcf00, 300, 220, 0xf000cfFF, 120, 300, 0xf0cF00FF );
		image.gradientShape.triangle( 100+120, 100+20, 0xccff0000, 300+120, 220+20, 0xcc0000FF, 120+120, 300+20, 0xcc00ff00 );
		image.putPixelImage( image, 45, 45 );

		// create new peote-view texture
		var texture = new Texture(512, 512);

		// put vision-image data into peote-view texture
		texture.setData(image);
		


		// -------------------------------------------------------------


		// set up a view, display, program and a buffer with one Element
		var peoteView = new PeoteView(window);
		var display   = new Display(10, 10, 512, 512, Color.GREY3);

		peoteView.addDisplay(display);  // display to view
		
		var buffer  = new Buffer<Elem>(10);
		var program = new Program(buffer);
		
		var element = new Elem(0, 0, 512, 512);
		buffer.addElement(element);
		
		// add texture to program
		program.setTexture(texture, "custom");
		//program.discardAtAlpha(0.1);
		program.blendEnabled = true;
			
		display.addProgram(program);  // programm to display
	}
	

}
