package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.view.*;
import pi_xy.Pixelimage;
import pi_xy.Pixelimage.ImageType;

class Elem implements Element {
	@posX public var x:Int;
	@posY public var y:Int;

	@sizeX public var w:Int;
	@sizeY public var h:Int;

	public function new(x:Int = 0, y:Int = 0, w:Int = 100, h:Int = 100) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}
}

class Main extends Application {
	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	// for original versino of this see - https://github.com/nanjizal/pi_xy_limeTest

	public function startSample(window:Window) {
		var image = new Pixelimage(800, 750);
		image.transparent = true;
		image.simpleRect(0, 0, image.width, image.height, 0xc9c3c3ff);

		var d = false;
		var Violet = 0xff9400D3;
		var Indigo = 0xff4b0082;
		var Blue =   0xff0000FF;
		var Green =  0xff00ff00;
		var Yellow = 0xffFFFF00;
		var Orange = 0xffFF7F00;
		var Red =    0xffFF0000;
		var scale = 10;
		var pixelTest = new pi_xy.Pixelimage( 80*scale, 80*scale );
		pixelTest.transparent = true;

		image.transparent = true;
		var colors = [Violet, Indigo, Blue, Green, Yellow, Orange, Red];
		var vertColor = colors[0];
		for (x in 0...70 * scale) {
			vertColor = colors[Math.floor((x / scale) / 10)];
			for (y in 0...768 - 70 - 45)
				pixelTest.setARGB(x, y, vertColor);
		}
		pixelTest.gradientShape.triangle(100, 100, 0xf0ffcf00, 300, 220, 0xf000cfFF, 120, 300, 0xf0cF00FF);
		pixelTest.gradientShape.triangle(100 + 120, 100 + 20, 0xccff0000, 300 + 120, 220 + 20, 0xcc0000FF, 120 + 120, 300 + 20, 0xcc00ff00);
		image.putPixelImage( pixelTest, 45, 45 );
		var texture = new Texture(image.width, image.height);

		// put image data into peote-view texture
		texture.setData(image);

		// -------------------------------------------------------------

		// set up a view, display, program and a buffer with one Element
		var peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.GREY3);

		peoteView.addDisplay(display); // display to view

		var buffer = new Buffer<Elem>(10);
		var program = new Program(buffer);

		var element = new Elem(0, 0, image.width, image.height);
		buffer.addElement(element);

		// add texture to program
		program.setTexture(texture, "custom");
		program.blendEnabled = true;

		// program to display
		display.addProgram(program); 
	}
}
