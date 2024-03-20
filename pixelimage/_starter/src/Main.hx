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
