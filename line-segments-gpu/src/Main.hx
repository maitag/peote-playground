package;

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
	var lineSegment:LineSegment;
	
	var isInit = false;
	
	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);

		buffer = new Buffer<LineSegment>(4, 4, true);
		var display = new Display(0, 0, window.width, window.height, Color.GREEN);
		var program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);

		
		lineSegment = new LineSegment();
		
		// line starts at middle of the window
		lineSegment.xStart = Std.int(window.width / 2);
		lineSegment.yStart = Std.int(window.height / 2);
		lineSegment.h = 3;
				
		buffer.addElement(lineSegment);
		
		isInit = true;
	}
	
	// ----------------- MOUSE EVENTS ------------------------------
	override function onMouseMove (x:Float, y:Float):Void {
		if (isInit) 
		{
			// calculating line width
			var a = lineSegment.xStart - x;
			var b = lineSegment.yStart - y;			
			lineSegment.w = Std.int( Math.sqrt( a * a + b * b ) );
			
			// calculating line rotation
			lineSegment.r = Math.atan2(x - lineSegment.xStart, - (y - lineSegment.yStart) )*(180 / Math.PI) - 90; // thx to halfwheat \o/
			
			buffer.updateElement(lineSegment);
		}
	}
	
	// -------------- WINDOWS EVENTS ----------------------------
	override function onWindowResize (width:Int, height:Int):Void {
		if (isInit) 
		{	// keep line starting at middle of the window on resize
			lineSegment.xStart = Std.int(width / 2);
			lineSegment.yStart = Std.int(height / 2);
		}
	}
	
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}	
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	
}
