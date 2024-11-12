package;

import haxe.Timer;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

class Main extends Application {
	var buffer:Buffer<Glyph>;

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
		var display = new Display(0, 0, window.width, window.height, Color.BLACK);
		peoteView.addDisplay(display);

		buffer = new Buffer<Glyph>(1024);
		var program = new Program(buffer);
		display.addProgram(program);
		// add the texture generated from VGA bits
		program.addTexture(new FontVGA());

		/// write a line of characters ...
		//////////////////////////////////

		var message = "hello world HALLO WELT";
		var size = 24;

		for (c in 0...message.length) {
			var x = c * size;
			var y = 0;
			var tile_index = message.charCodeAt(c);
			var glyph = new Glyph(x, y, size, tile_index);
			glyph.color = Color.LIME;
			buffer.addElement(glyph);
		}

		/// make a grid of characters and animate them
		//////////////////////////////////////////////

		var size = 16;
		var columns = 25;
		var rows = 25;
		var x = 62;
		var y = 40;

		// initial ascii character code
		var char_code = "!".charCodeAt(0);

		var glyphs:Array<Glyph> = [
			for (index in 0...columns * rows) {
				var c = index % columns;
				var r = Std.int(index / columns);
				buffer.addElement(new Glyph(x + (c * size), y + (r * size), size, char_code));
			}
		];

		// timer to increment character ever 5 milliseconds
		var index = 0;
		new Timer(5).run = () -> {
			var glyph = glyphs[index];

			// increment char code
			glyph.tile_index = (glyph.tile_index + 1) % 128;

			// increment element index (wrapped to max index)
			index = (index + 1) % glyphs.length;
		}

		// timer to randomize colors in increasingly longer sections
		var index = 0;
		var section_length = 1;
		new Timer(5 * columns).run = () -> {
			// random color (clamped to keep it visible against black display)
			var color = Color.random() | 0x202020FF;

			for (i in index...index + section_length) {
				// keep element index within max range
				var n = i % glyphs.length;

				// set the color
				glyphs[n].color = color;

				index = (index + 1) % glyphs.length;
			}

			// increment the section length (wrapped to max index)
			section_length = (section_length + 1) % glyphs.length;
		}
	}

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------

	override function update(deltaTime:Int):Void {
		buffer.update();
	}

	// override function onPreloadComplete():Void {}
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
