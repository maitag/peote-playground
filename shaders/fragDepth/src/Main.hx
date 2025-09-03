package;

import haxe.CallStack;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseWheelMode;
import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;
import peote.view.Texture;
import peote.view.Load;

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
	
	var movingTile:DepthPerPixel = null;
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);		
		var display = new Display(0, 0, window.width, window.height);
		peoteView.addDisplay(display);
		
		Load.image("assets/object_bw_depth_alpha.png", true, function (image:Image)
		{
			var tilesTexture = new Texture(image.width, image.height); // , 1, 4, false, 0, 0);
			tilesTexture.setData(image);
			
			// how many tiles into x and y direction
			tilesTexture.tilesX = 5;
			tilesTexture.tilesY = 1;
						
			DepthPerPixel.init(display, tilesTexture);
			
			// depend on movingTiles depth-value the drawing order here can be important
			var tile0 = new DepthPerPixel(200, 200, 128, 128, 0);
			var tile1 = new DepthPerPixel(300, 200, 128, 128, 1);
			var tile2 = new DepthPerPixel(400, 200, 128, 128, 2);
			var tile3 = new DepthPerPixel(500, 200, 128, 128, 3);
			var tile4 = new DepthPerPixel(564, 200, 128, 128, 4);
			movingTile = new DepthPerPixel(200, 200, 128, 128, 1);
			
			// add mouse events to move the light (to not run before it was instantiated):
			window.onMouseMove.add(_onMouseMove);
			window.onMouseWheel.add(_onMouseWheel);
		});
				
	}
	
	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	
	function _onMouseMove (x:Float, y:Float):Void {
		movingTile.x = Std.int(x);
		movingTile.y = Std.int(y);
		movingTile.update();
	}	

	function _onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		movingTile.depth += ( (deltaY > 0) ? 1 : -1  ) * 0.05;
		if (movingTile.depth > 2/3) movingTile.depth = 2/3;
		if (movingTile.depth < 0) movingTile.depth = 0;
		trace("depth:" + movingTile.depth);
		movingTile.update();
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
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}	
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	
}
