package;

import NanjizalDraw.DrawPixel;
import NanjizalDraw.DrawLine;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;


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
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------
	var buffer_lines:Buffer<LineSegment>;
	var buffer_pixels:Buffer<Pixel>;
	
	var isInit = false;
	
	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.BLACK);
		peoteView.addDisplay(display);

		buffer_lines = new Buffer<LineSegment>(16384, 1024, true);
		var program_lines = new Program(buffer_lines);
		display.addProgram(program_lines);

		buffer_pixels = new Buffer<Pixel>(65535, 4096, true);
		var program_pixels = new Program(buffer_pixels);
		display.addProgram(program_pixels);

		var drawLine:DrawLine = (x0, y0, x1, y1, thick, color) -> {
			var line = new LineSegment();
			line.xStart = Std.int(x0);
			line.yStart = Std.int(y0);
			line.xEnd = Std.int(x1);
			line.yEnd = Std.int(y1);
			line.c = color;
			line.h = Std.int(thick);
			buffer_lines.addElement(line);
		}

		var drawPixel:DrawPixel = (x, y, color) -> {
			buffer_pixels.addElement(new Pixel(x, y, color));
		}
		
		var nanj = new NanjizalDraw(drawLine, drawPixel);
		
		nanj.strokeWidth = 2;
		nanj.strokeColor = Color.GREEN;
		nanj.moveTo( 100, 100 );
		nanj.lineTo( 200, 150 );
		nanj.lineTo( 130, 220 );
		nanj.lineTo( 100, 100 );

		// fill is work in progress (not currently working)
		nanj.fillTriangle( 100, 100, 200, 150, 130, 220 );
		nanj.fillQuadrilateral( 500, 300, 530, 220, 700, 120, 900, 500 );
		nanj.strokeWidth = 50;
		nanj.strokeColor = Color.MAGENTA;
		// issue with moveTo?
		nanj.moveTo( 400, 200 );
		nanj.quadTo( 400, 20, 500, 500);

		// testing drawPixel
		@:privateAccess
		nanj.drawPixel(400, 400, Color.WHITE);
		
		isInit = true;
		
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
