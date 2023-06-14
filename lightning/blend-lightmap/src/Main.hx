package;

import peote.view.utils.BlendFactor;
import peote.view.utils.BlendFunc;
import lime.utils.Assets;
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
	var light:Sprite;
	var lightBuffer:Buffer<Sprite>;

	var blendElement:BlendElement;
	var blendBuffer:Buffer<BlendElement>;

	override function onPreloadComplete():Void {
		// access embeded assets from here
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
		// hide mouse cursor
		window.cursor = null;

		var peoteView = new PeoteView(window);

		// wabbits
		// --------------

		// display for wabbits
		var backgroundColor = 0xffffffff;
		var wabbitsDisplay = new Display(0, 0, window.width, window.height, backgroundColor);
		peoteView.addDisplay(wabbitsDisplay);

		// wabbit program
		var wabbitCount = 1000;
		var wabbitBuffer = new Buffer<Sprite>(wabbitCount);
		var wabbitProgram = new Program(wabbitBuffer);
		wabbitsDisplay.addProgram(wabbitProgram);

		// load wabbit texture and give to program
		var wabbitImage = Assets.getImage("assets/wabbit_alpha.png");
		var wabbitTexture = new Texture(wabbitImage.width, wabbitImage.height);
		wabbitTexture.setImage(wabbitImage);
		wabbitProgram.addTexture(wabbitTexture, "wabbit");

		// add wabbit Sprites
		for (n in 0...wabbitCount) {
			var x = Std.int(Math.random() * window.width);
			var y = Std.int(Math.random() * window.height);
			var tint:Color = 0xffffffff;
			var wabbit = new Sprite(x, y, wabbitImage.width, wabbitImage.height, tint);
			wabbitBuffer.addElement(wabbit);
		}

		// lights
		// --------------

		// display for lighting framebuffer - will render all light Elements to a texture
		var lightingFbo = new Display(0, 0, window.width, window.height);
		peoteView.addFramebufferDisplay(lightingFbo);
		// the texture which the lighting display will render to
		var lightingTexture = new Texture(window.width, window.height);
		lightingFbo.setFramebuffer(lightingTexture, peoteView);

		// lights program - renders to lightingFbo (display)
		var lightCount = 11;
		lightBuffer = new Buffer<Sprite>(lightCount, true);
		var lightProgram = new Program(lightBuffer);
		lightingFbo.addProgram(lightProgram);

		// important ! enable blending
		lightProgram.blendEnabled = true;
		
		// load a texture to be used for each 'light'
		var lightImage = Assets.getImage("assets/white_alpha_gradient-sinusoidal.png");
		var lightTexture = new Texture(lightImage.width, lightImage.height);
		lightTexture.setImage(lightImage);
		lightProgram.addTexture(lightTexture, "light");

		// add a light which will follow mouse position
		var tint:Color = 0xffffffff;
		light = new Sprite(0, 0, lightImage.width, lightImage.height, tint);
		lightBuffer.addElement(light);

		// add some more lights, with colors
		var extraLightCount = lightCount - 1; // 1 is following mouse
		for (n in 0...extraLightCount) {
			// random position
			var x = Std.int(Math.random() * window.width);
			var y = Std.int(Math.random() * window.height);

			// random size
			var sizeMin = 200;
			var sizeMax = 500;
			var size = Std.int(Math.random() * (sizeMax - sizeMin)) + sizeMin;

			// random tint
			var tint:Color = 0xffffffff;
			tint.r = Std.int(255 * Math.random());
			tint.g = Std.int(255 * Math.random());
			tint.b = Std.int(255 * Math.random());

			var extraLight = new Sprite(x, y, size, size, tint);
			lightBuffer.addElement(extraLight);
		}

		// blend
		// --------------

		// lighting display - blends alpha of lightingFbo texture to let wabbits be seen behind!
		var lightingDisplay = new Display(0, 0, window.width, window.height);
		peoteView.addDisplay(lightingDisplay);

		// blend program - renders to main display
		blendBuffer = new Buffer<BlendElement>(1);
		var blendProgram = new Program(blendBuffer);
		lightingDisplay.addProgram(blendProgram);
		
		// set up the blend options 
		blendProgram.blendEnabled = true;
		blendProgram.blendFunc = BlendFunc.ADD;
		blendProgram.blendSrc = BlendFactor.ZERO;
		blendProgram.blendDst = BlendFactor.SRC_COLOR;
		
		blendProgram.discardAtAlpha(null);
		
		// give fbo texture to program, this texture has all the 'lights' rendered to i
		blendProgram.addTexture(lightingTexture, "lights");

		// BlendElement will render the final program
		var lightsElement = new BlendElement(0, 0, window.width, window.height);
		blendBuffer.addElement(lightsElement);
	}

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------

	override function onMouseMove(x:Float, y:Float):Void {
		// change light position to mouse position
		light.x = Std.int(x);
		light.y = Std.int(y);
		lightBuffer.updateElement(light);
	}

	override function onMouseWheel(deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {
		// scroll wheel make mouse follower thic
		var sizeChange = Std.int(25 * deltaY);
		light.w += sizeChange;
		light.h += sizeChange;
		lightBuffer.updateElement(light);
	}

	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");
	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
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
