package;

import haxe.CallStack;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseWheelMode;
import lime.graphics.Image;

import peote.view.*;

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
	
	var light:NormalLight = null; 
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		var display = new Display(0, 0, 512, 512);

		peoteView.addDisplay(display);
		
		Load.imageArray(["assets/mandelbulb_light_alpha0001.png", "assets/mandelbulb_normal0001.png"] , true, function (image:Array<Image>)
		{
			var lightsTexture = new Texture(image[0].width, image[0].height); // , 1, 4, false, 0, 0);
			lightsTexture.setData(image[0]);
			
			var normalTexture = new Texture(image[1].width, image[1].height); // , 1, 4, false, 0, 0);
			normalTexture.setData(image[1]);

			
			// TODO: render all into Texture per frame!
			
			// TODO: only need normalTexture here
			NormalLight.init(display, lightsTexture, normalTexture);
			light = new NormalLight(200, 200, 1024, 0.25, Color.RED);

			// "add" (blendmode!) another light
			for (i in 0...2048) new NormalLight(Std.random(1024), Std.random(1024), 128 + Std.random(64), Math.random()*.6,  Color.random(255));
			
			// TODO: better render color-texture at first and then into a second program all the lights into "add" mode
			
			
			
			
			
			// add mouse events to move the light (to not run before it was instantiated):
			window.onMouseMove.add(_onMouseMove);
			window.onMouseWheel.add(_onMouseWheel);
		});
		
		
		//peoteView.start();
		
	}
	
	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	
	function _onMouseMove (x:Float, y:Float):Void {
		light.x = Std.int(x);
		light.y = Std.int(y);
		light.update();
	}	

	var isShift = false;
	
	function _onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		if (isShift) {
			light.size += ( (deltaY > 0) ? 1 : -1  ) * 10;
		}
		else {
			light.depth += ( (deltaY > 0) ? 1 : -1  ) * 0.01;
		}
		trace(light.depth);
		light.update();
	}
	// ----------------- MOUSE EVENTS ------------------------------
	
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseMove (x:Float, y:Float):Void {
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		if (keyCode == KeyCode.LEFT_SHIFT) isShift = true;
	}	
	override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		if (keyCode == KeyCode.LEFT_SHIFT) isShift = false;
	}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	
}
