package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;
import peote.view.Texture;
import utils.Loader;
import lime.graphics.Image;


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
	var peoteView:PeoteView;
	var shaking:Shaking; 
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.BLACK);

		peoteView.addDisplay(display);

		
		// electric bolt like shader
		ElectroBolts.init(display); new ElectroBolts(0, 200, 800, 200);
		// from top to down
		//ElectroBolts.init(display); new ElectroBolts(300, 0, 200, 800);
		
		// shaking
		Loader.image ("assets/test0.png", true, function (image:Image) {
			var texture = new Texture(image.width, image.height);
			texture.setImage(image);
			Shaking.init(display, texture); shaking = new Shaking(20, 20, 200, 150);
		});
		
		peoteView.start();
	}
	
	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// ----------------- MOUSE EVENTS ------------------------------
	
	override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void
	{
		shaking.shake(peoteView.time);
	}
	
	// override function onMouseMove (x:Float, y:Float):Void {}	
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
