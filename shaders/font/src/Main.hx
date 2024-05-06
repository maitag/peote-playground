package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.Image;

import peote.view.*;
import utils.Loader;


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
	
	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.GREY1);

		peoteView.addDisplay(display);

		Glyph.init(display);

		var cursorX = 0;
		var scale = 10;

		var w = 8 * scale;
		var h = 12 * scale;

		new Glyph(cursorX     , 0, w, h, 'H', Color.GOLD, Color.BLUE);
		new Glyph(cursorX += w, 0, w, h, 'e', Color.GOLD, Color.BLUE);
		new Glyph(cursorX += w, 0, w, h, 'l', Color.GOLD, Color.BLUE);
		new Glyph(cursorX += w, 0, w, h, 'l', Color.GOLD, Color.BLUE);
		new Glyph(cursorX += w, 0, w, h, 'o', Color.GOLD, Color.BLUE);
		new Glyph(cursorX += w, 0, w, h, ' ', Color.ORANGE);
		new Glyph(cursorX += w, 0, w, h, '\\',Color.ORANGE);
		new Glyph(cursorX += w, 0, w, h, 'o', Color.ORANGE);
		new Glyph(cursorX += w, 0, w, h, '/', Color.ORANGE);
		
	}
	


	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// ----------------- MOUSE EVENTS ------------------------------

	//override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}	
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	
}
