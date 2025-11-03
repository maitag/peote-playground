package perspective;

import lime.ui.KeyModifier;
import lime.ui.KeyCode;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.view.*;

class TestElement3D extends Application
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
	var element:Element3D;

	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.BLACK);
		peoteView.addDisplay(display);		

		Element3D.init(display, 1);
		element = new Element3D(0, 0, 400, 300);
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
		}

		element.update();		
	}
	
	var isShift = false;
	override function onKeyDown(code:KeyCode, modifier:KeyModifier):Void
	{
		switch code {
			case LEFT_SHIFT: isShift = true;
			case RIGHT:
				if (element.tipX<1.0) element.tipX += 0.1;
			case LEFT:
				if (element.tipX>-1.0) element.tipX -= 0.1;
			case UP:
				if (element.tipY<1.0) element.tipY += 0.1;
			case DOWN:
				if (element.tipY>-1.0)element.tipY -= 0.1;
			case NUMPAD_0:
				element.tipX = element.tipY = 0.0;
				element.w = 400;
				element.h = 300;
				element.r = 0;
				rotationX = 0;
				rotationY = 0;
			case D: element.px += 0.1;
			case A: element.px -= 0.1;
			case S: element.py += 0.1;
			case W: element.py -= 0.1;
			case Q:
				element.r -= 5;
			case E:
				element.r += 5;
			case _:
		}

		// trace('tipX:${element.tipX}, tipY:${element.tipY}, ');

		element.update();
	}
	override function onKeyUp (code:KeyCode, modifier:KeyModifier):Void {
		switch code {
			case LEFT_SHIFT: isShift = false;
			case _:
		}
	}

	var rotationX:Float = 0.0;
	var rotationY:Float = 0.0;

	override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {
		if (element == null) return;

		if (isShift)
		{
			rotationX = ( rotationX + 5 * ((deltaY>0)?1:-1) ) % 360;
			if (rotationX < 0) rotationX = 360 + rotationX;

			element.tipX = Math.sin( rotationX/360 * Math.PI *2 );

			element.h = 300 * Math.cos( rotationX/360 * Math.PI *2) ;
		} 
		else
		{
			rotationY = ( rotationY + 5 * ((deltaY>0)?1:-1) ) % 360;
			if (rotationY < 0) rotationY = 360 + rotationY; 

			element.tipY = Math.sin( rotationY/360 * Math.PI *2 );

			element.w = 400 * Math.cos( rotationY/360 * Math.PI *2) ;
		}

		trace('rotationX:$rotationX, rotationY:$rotationY');

		element.update();
	}
	
	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	
}
