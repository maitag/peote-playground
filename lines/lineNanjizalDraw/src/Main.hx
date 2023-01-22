package;

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
	var buffer:Buffer<LineSegment>;
	
	var isInit = false;
	
	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);

		buffer = new Buffer<LineSegment>(4, 4, true);
		var display = new Display(0, 0, window.width, window.height, Color.BLACK);
		var program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);

		var drawLine:DrawLine = (x0, y0, x1, y1, thick, color) -> {
			var line = new LineSegment();
			line.xStart = Std.int(x0);
			line.yStart = Std.int(y0);
			line.xEnd = Std.int(x1);
			line.yEnd = Std.int(y1);
			line.c = color;
			line.h = Std.int(thick);
			buffer.addElement(line);
		}

		
		
		var nanj = new NanjizalDraw(drawLine);
		
		nanj.strokeWidth = 2;
		nanj.strokeColor = Color.GREEN;
		nanj.moveTo( 100, 100 );
		nanj.lineTo( 200, 150 );
		nanj.lineTo( 130, 220 );
		nanj.lineTo( 100, 100 );
		
		// fill is work in progress (not currently working)
		nanj.fillTriangle( 100, 100, 200, 150, 130, 220 );

		nanj.strokeWidth = 10;
		nanj.strokeColor = Color.MAGENTA;
		// issue with moveTo?
		nanj.moveTo( 400, 200 );
		nanj.quadTo( 400,0, 500,500);
		
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
