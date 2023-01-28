package;

import NanjizalDraw.DrawPixel;
//import NanjizalDraw.DrawLine;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;


class MainPixelAnim extends Application
{
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------
	
	//var buffer_pixels:Buffer<Pixel>;
	var buffer_pixels:Buffer<PixelAnim>;
	
	var nanj:NanjizalDraw;
	
	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window, Color.GREY1);
		//var display = new Display(0, 0, window.width, window.height, Color.BLACK);
		var display = new Display(0, 0, 800, 600, Color.BLACK);
		peoteView.addDisplay(display);

		//buffer_pixels = new Buffer<Pixel>(65535, 4096, true);
		buffer_pixels = new Buffer<PixelAnim>(65535, 4096, true);
		var program_pixels = new Program(buffer_pixels);
		display.addProgram(program_pixels);

		var drawPixel:DrawPixel = (x, y, color) -> {
			//buffer_pixels.addElement(new Pixel(x, y, color));
			buffer_pixels.addElement(new PixelAnim(x, y, color));
		}
		
		nanj = new NanjizalDraw(null, drawPixel);
		
		gimmeMaze(110, 75, 50, 50);
		
		display.zoom = 3.0;
		
		haxe.Timer.delay( ()->peoteView.start() , 1500);
	}
	
	// --------- drawing maze ----------
	
	var hasPixel:haxe.ds.Vector<Bool>;
	
	public function gimmeMaze(xStart:Int, yStart:Int, width:Int, height:Int) {
		hasPixel = new haxe.ds.Vector<Bool>(width * height);
		_gimmeMaze(xStart, yStart, width, height, 1, 1);
	}
	
	@:access(NanjizalDraw)
	inline function setPixel(xStart:Int, yStart:Int, width:Int, x:Int, y:Int) {
	  nanj.drawPixel(xStart + x, yStart + y, Color.GREEN);
	  hasPixel.set(y * width + x, true);
	}
	
	public function _gimmeMaze(xStart:Int, yStart:Int, width:Int, height:Int, x:Int, y:Int) {
		setPixel(xStart, yStart, width, x, y);
		var d = [-2, 0, 0, 2, 2, 0, 0, -2];
		while (d.length > 0)
		{
			var i = d.splice( 2 * Math.floor( Math.random()*d.length/2 ), 2);
			var a = x + i[0];
			var b = y + i[1];
			if (a<0 || b<0 || a>=width || b>=height) continue;
			if (hasPixel.get(b * width + a)) continue;
			if (a != x) setPixel(xStart, yStart, width, Math.floor(x + ((a - x) / 2)), b);
			else setPixel(xStart, yStart, width, a, Math.floor(y + ((b - y) / 2)));
			_gimmeMaze(xStart, yStart, width, height, a, b);
		}
		
	}
	
	
	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseMove (x:Float, y:Float):Void {}
	
	// -------------- WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void {}
	
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}	
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	
}
