package;

import haxe.CallStack;
import haxe.io.Bytes;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

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
	
	public var peoteView:PeoteView;
	public var buffer:Buffer<Emitter>;
	public var display:Display;
	public var program:Program;

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		display = new Display(10, 10, window.width - 20, window.height - 20, Color.BLACK);
		peoteView.addDisplay(display);

		buffer = new Buffer<Emitter>(4, 4, true);
		program = new Program(buffer);
		display.addProgram(program);

		loadSound();
	}

	// load multiple sound-waves
	public function loadSound()
	{
		Loader.bytesArray(
			[
				// filenames here
			],
			false,

			// --------------------- progress handler ---------------------
			function(index:Int, loaded:Int, size:Int) {
				trace(' $index progress ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
			},

			function(loaded:Int, size:Int) {
				trace(' Progress overall: ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
			},

			// --------------------- load handler ---------------------
			function(index:Int, bytes:Bytes) {
				trace('$index loaded completely.');
			},

			function(bytesArray:Array<Bytes>) {
				trace(' --- all data loaded ---');
			}			
		);
	}
	
	// after all sounds is loaded
	public function onAllSoundLoaded()
	{

		var bird = new Emitter(100, 100, 32, 32, Color.RED1, Color.GREEN3, 0.9);
		buffer.addElement(bird);

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
