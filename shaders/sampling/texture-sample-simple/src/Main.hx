package;

import peote.view.Texture;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

class Main extends Application {
	var spriteBuffer:Buffer<Sprite>;
	var sprite:Sprite;

	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------

	public function startSample(window:Window) {
		var peoteView = new PeoteView(window);

		// main display
		var display = new Display(0, 0, window.width, window.height, Color.CYAN);
		peoteView.addDisplay(display);

		// new display which will render to a texture
		var texture_display = new Display(0, 0, window.width, window.height);
		peoteView.addFramebufferDisplay(texture_display);

		// the texture which the display will render to
		var texture = new Texture(window.width, window.height);
		texture_display.setFramebuffer(texture, peoteView);

		// spriteProgram to draw on texture_display (and therefore the texture)
		spriteBuffer = new Buffer<Sprite>(4, 4, true);
		var spriteProgram = new Program(spriteBuffer);

		// add sprite program to texture display
		texture_display.addProgram(spriteProgram);

		// init the Sprite
		sprite = new Sprite(0, 0, 100, 100, 0xff0000ff);
		spriteBuffer.addElement(sprite);

		// currently the Sprite is not visible because
		// the texture_display is not added to PeoteView
		// below we set up a new program that will render the texture which texture_display is producing

		// make new buffer and program to render the texture
		var renderBuffer = new Buffer<RenderElement>(1);
		var renderProgram = new Program(renderBuffer);

		// ! enable alpha (otherwise we can only handle 0.0 or 1.0 alpha, nothing in between)
		renderProgram.alphaEnabled = true;

		// add render program to main display
		display.addProgram(renderProgram);

		// add the texture to the program
		renderProgram.addTexture(texture, "sampledtexture");

		// inject glsl function which samples the color from "sampledtexture" at vTexCoord
		renderProgram.injectIntoFragmentShader("
		vec4 getColor(int sampledtexture){

			// sample the texture
			vec4 sample = getTextureColor(sampledtexture, vTexCoord);
			
			// if the sample red is 100% red
			if(sample.r == 1.0){
				// return transparent color
				return vec4(0.0, 0.0, 0.0, 0.0);
			}

			// otherwise return black with some transparency
			return vec4(0.0,0.0,0.0,0.7);
		}
		");

		// set program to use glsl function for the color
		renderProgram.setColorFormula('getColor(sampledtexture_ID)');

		// add new element to render buffer so that the render program has something to draw
		renderBuffer.addElement(new RenderElement(0, 0, window.width, window.height));
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

	override function onMouseMove(x:Float, y:Float):Void {
		sprite.x = Std.int(x);
		sprite.y = Std.int(y);
		spriteBuffer.updateElement(sprite);
	}

	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");
	// ----------------- MOUSE EVENTS ------------------------------
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
