package perspective;

import lime.ui.KeyModifier;
import lime.ui.KeyCode;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.view.*;

class TestPerspectiveXY extends Application
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
	var element:PerspectiveXY;

	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.BLACK);
		peoteView.addDisplay(display);		

		PerspectiveXY.init(display, 1);
		element = new PerspectiveXY(0, 0, 400, 300, 1.0, 1.0);
		// element.py = 150;
		
	}
	
	// ----------------- MOUSE EVENTS ------------------------------
	var clickMode = false;	
	var clickX:Float = 0;	
	var clickY:Float = 0;
	var clickTiltX:Float = 0;	
	var clickTiltY:Float = 0;

	override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {
		clickX = x;
		clickY = y;
		clickTiltX = element.tiltX;
		clickTiltY = element.tiltY;
		clickMode = true;
	}
	override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {
		clickMode = false;
	}
	override function onMouseMove (x:Float, y:Float):Void {
		if (element == null) return;

		element.x = x;
		element.y = y;

		if (clickMode) {
			element.tiltX = clickTiltX + (clickX - x)/element.w;
			element.tiltY = clickTiltY + (clickY - y)/element.h;
		}

		element.update();		
	}
	
	override function onKeyDown(code:KeyCode, modifier:KeyModifier):Void
	{
		switch code {
			case RIGHT:
				element.tipX *= 1.05;
			case LEFT:
				element.tipX /= 1.05;
			case DOWN:
				element.tipY += 0.1;
			case UP:
				element.tipY -= 0.1;
			case NUMPAD_0:
				element.tipX = element.tipY = 1.0;
				element.tiltX =  element.tiltY = 0.5;
				element.w = 400;
				element.h = 300;
				element.r = 0;
				rotation = 0;
			case NUMPAD_6: element.px += 0.1;
			case NUMPAD_4: element.px -= 0.1;
			case NUMPAD_8: element.py += 0.1;
			case NUMPAD_2: element.py -= 0.1;
			case Q:
				element.r -= 5;
			case E:
				element.r += 5;
			case _:
		}

		// element.w = 400*Math.cos( (Math.abs(element.tipX-1))*Math.PI/1.0 );
		element.update();
	}
	
	var rotation:Float = 0.0;

	override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {
		if (element == null) return;

		rotation = ( rotation + 5 * ((deltaY>0)?1:-1) ) % 360;
		if (rotation < 0) rotation = 360 + rotation; 
		trace(rotation);

		element.tipX = 1 + Math.abs(  Math.sin( rotation/360 * Math.PI *2 ) );
		
		element.w = 400 * Math.cos( rotation/360 * Math.PI *2) ;
		// element.h = 300 / element.tipX; // rotate about left side
		element.h = 300 / (1+(element.tipX-1)*0.5);

		element.update();
	}
	
	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	
}
