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
					element.tipX += 0.1;
				case LEFT:
					element.tipX -= 0.1;
				case DOWN:
					element.tipY += 0.1;
				case UP:
					element.tipY -= 0.1;
				case NUMPAD_0:
					element.tipX = element.tipY = 1.0;
					element.tiltX =  element.tiltY = 0.5;
				case _:
			}
	
			element.update();
		}
	
	override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {
		if (element == null) return;

		
	}
	
	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	
}
