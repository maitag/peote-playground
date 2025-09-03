package;

import haxe.CallStack;

import lime.ui.Window;
import lime.app.Application;
import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Texture;
import peote.view.Color;
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
	
	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);
		peoteView.zoom = 4; // zoom in so we can see the texture details easily

		var buffer = new Buffer<Sprite>(4, 4, true);
		var display = new Display(0, 0, window.width, window.height, Color.GREY3);
		var program = new Program(buffer);
		
		peoteView.addDisplay(display);
		display.addProgram(program);

		Load.image("assets/test.png", (image:Image) -> {

			// program.addTexture(Texture.fromData(TextureData.RGBAfrom(image)), "test");
			program.addTexture(Texture.fromData(image), "test");

			// the clipped area we want to render is positioned at x 32 y 32 and is 48 pixels square
			var clipWidth = 48;
			var clipHeight = 48;

			// this 'clipped' Sprite instance shows clipped section of the full texture
			var clipped = new Sprite();
			
			// set the width and height of the element to the size of the clip
			clipped.w = clipWidth;
			clipped.h = clipHeight;

			// set the and y position of the clip area within the texture
			clipped.clipX = 32;
			clipped.clipY = 32;

			// set the size of the clip area within the texture
			clipped.clipWidth = clipWidth;
			clipped.clipHeight = clipHeight;
			clipped.clipSizeX = clipWidth;
			clipped.clipSizeY = clipHeight;

			buffer.addElement(clipped);

			// this 'padded' Sprite instance shows the same clipped section of the full texture
			// plus 10 pixels of padding
			var padded = new Sprite();
			padded.x = 64; // set the position of the element so it does not overlap the other Elements
			
			var padding = 10;
			// set the same clip attributes as the clipped instance
			padded.clipX = 32;
			padded.clipY = 32;
			padded.clipWidth = clipWidth;
			padded.clipHeight = clipHeight;
			

			// width and height of the element is the size of the clip plus padding
			padded.w = clipWidth + padding;
			padded.h = clipWidth + padding;

			// offset the clip size by the padding
			padded.clipSizeX = clipWidth - padding;
			padded.clipSizeY = clipHeight - padding;

			// offset the clip position by half of the padding 
			padded.clipPosX = Std.int(padding / 2);
			padded.clipPosY = Std.int(padding / 2);

			buffer.addElement(padded);

			// this 'paddedAlpha' Sprite instance shows the same clipped section of the full texture
			// plus 10 pixels of padding
			// the edges of section in the texture are transparent
			var paddedAlpha = new Sprite();
			paddedAlpha.x = 128; // set the position of the element so it does not overlap the other Elements
			
			// set the same clip attributes as the clipped instance but in a different y position
			paddedAlpha.clipX = 32;
			paddedAlpha.clipY = 128;
			paddedAlpha.clipWidth = clipWidth;
			paddedAlpha.clipHeight = clipHeight;
			
			// width and height of the element is the size of the clip plus padding
			paddedAlpha.w = clipWidth + padding;
			paddedAlpha.h = clipWidth + padding;

			// offset the clip size by the padding
			paddedAlpha.clipSizeX = clipWidth - padding;
			paddedAlpha.clipSizeY = clipHeight - padding;

			// offset the clip position by half of the padding 
			paddedAlpha.clipPosX = Std.int(padding / 2);
			paddedAlpha.clipPosY = Std.int(padding / 2);

			buffer.addElement(paddedAlpha);
			
		});
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	override function onPreloadComplete():Void {
		// access embeded assets from here
	}

	override function update(deltaTime:Int):Void {
		// for game-logic update
	}

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
