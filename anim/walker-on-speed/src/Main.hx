package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.Image;

import peote.view.*;
import peote.view.TextureData;
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

		var buffer = new Buffer<Walker>(4, 4, true);
		var display = new Display(0, 0, window.width, window.height, Color.GREY1);
		var program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);
		
		Loader.bytes("assets/walkGreyAlpha.png", true, function(bytes:haxe.io.Bytes)
		{
			var texture = new Texture(1024, 384, {format:TextureFormat.LUMINANCE_ALPHA});
			texture.setData( TextureData.fromFormatPNG(bytes) );

			texture.tilesX = 8;
			texture.tilesY = 3;
	
			program.addTexture(texture, "custom");


			var walker = new Walker();
			walker.y = 0;

			buffer.addElement(walker);

			walker.animX(-128, window.width); // params: startX, endX
			walker.timeX(0.0, 2.3); // params: start-time, duration
			
			
			// don't forget to update after changing for tile-anim!
			buffer.updateElement(walker);
			
			
			// after this the "peote time" counts up !
			peoteView.start();
		});
	
	}
	



	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// override function onPreloadComplete():Void {
		// access embeded assets from here
	// }

	// override function update(deltaTime:Int):Void {
		// for game-logic update
	// }

	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");		

	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseMove (x:Float, y:Float):Void {}	
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
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
	// override function onWindowLeave():Void { trace("onWindowLeave"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
	
}
