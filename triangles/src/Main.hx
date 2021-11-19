package;

import haxe.CallStack;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

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
	var helper:LineSegment;
	var tri:Tri;
	
	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);

		var display = new Display(0, 0, window.width, window.height);
		peoteView.addDisplay(display);

		buffer = new Buffer<LineSegment>(4, 4, true);
		var program = new Program(buffer);
		display.addProgram(program);

		
		lineSegment = new LineSegment(
			100, 300,
			400, 300,
			250, 200, Color.BLUE
		);
		buffer.addElement(lineSegment);
		
		helper = new LineSegment(
			100, 300,
			250, 300,
			300, 200, Color.YELLOW
		);
		buffer.addElement(helper);
		
		// ------------------------------
		Tri.init(display);
		
		tri = new Tri(			
			100, 300, Color.RED,
			400, 300, Color.GREEN,
			250, 200, Color.BLUE
		);

	}
	
	// ----------------- MOUSE EVENTS ------------------------------
	
	var isMouseDown = false;
	var point:Int = 2;
	
	override function onMouseMove (x:Float, y:Float):Void {
		if (isMouseDown) 
		{
			switch (point) {
				case 0:
					lineSegment.x0 = helper.x0 = tri.x0 = x;
					lineSegment.y0 = helper.y0 = tri.y0 = y;
				case 1:
					lineSegment.x1 = helper.x1 = tri.x1 = x;
					lineSegment.y1 = helper.y1 = tri.y1 = y;
				case 2:
					lineSegment.x2 = helper.x2 = tri.x2 = x;
					lineSegment.y2 = helper.y2 = tri.y2 = y;
			}
			
			lineSegment.update();			
			buffer.updateElement(lineSegment);
			
			helper.update();
			var a = lineSegment.x0 - lineSegment.x2;
			var b = lineSegment.y0 - lineSegment.y2;
			var c =  Math.sqrt( a * a + b * b );
			helper.w = Math.sqrt( c * c - lineSegment.h * lineSegment.h );
			
			a = lineSegment.x1 - lineSegment.x2;
			b = lineSegment.y1 - lineSegment.y2;
			
			// Problem:
			//if ( a*a + b*b > lineSegment.w * lineSegment.w + lineSegment.h * lineSegment.h) helper.w = -helper.w;
		
			buffer.updateElement(helper);
			
			// ------------------
			tri.update();
			
		}
	}
	
	// -------------- WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void {}
	
	override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {
		isMouseDown = true;
	}	
	override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {
		isMouseDown = false;
		//point = (point + 1) % 3;
	}	
	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void {
		switch (keyCode) {
			case KeyCode.NUMBER_1: point=0;
			case KeyCode.NUMBER_2: point=1;
			case KeyCode.NUMBER_3: point=2;
				
			default:
		}
		
	}	
	
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	
}
