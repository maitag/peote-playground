package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

class MainShower extends Application
{
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	var peoteView:PeoteView;
	var emitterDisplay:EmitterDisplay;

	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window, 0x000020ff);

		peoteView.xZoom = window.width/800;
		peoteView.yZoom = window.height/600;

		emitterDisplay = new EmitterDisplay(100, 100, 300, 300, Color.BLACK);
		peoteView.addDisplay(emitterDisplay);
		
	
		trace('Please click many times !');
		window.onMouseDown.add((f1, f2, button) -> {
			emitterDisplay.spawn( 
				SHOWER, // type (formula)
				{
					steps: 50, // timesteps (how often particles spawns)
	
					ex: 150, ey:0, // emitter position
					sx: random(-75, 75), sy:emitterDisplay.height, // how far the particles goes away over time
	
					spawn:3, // amount of particles what spawn per time-step
					spawnFunc:(spawn, step)->{return spawn + step;}, // to mod spawn in depend of timestep
	
					delay:200, // time before next spawn
					delayFunc:(delay, step)->{return Std.int(delay - step);}, // to mod delay in depend of timestep
	
					duration:700, // how long a particlespawn exist
					durationFunc:(duration, step)->{return Std.int(duration - step);}, // to mod duration in depend of timestep
	
					colorStart: 0x0000ffFF,
					colorEnd: 0xffffff00,
				}
			);
		});

		// time to s t a r t:
		peoteView.start();
	}
	
	public function random(min:Int, max:Int) return min + Std.random(max + 1 - min);
	//--------------------------------------------
	// ----------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// access embeded assets from here
	// override function onPreloadComplete():Void {}

	// for game-logic update
	// override function update(deltaTime:Int):Void {}

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
	override function onWindowResize (width:Int, height:Int):Void {
		// trace("onWindowResize", width, height);
		peoteView.xZoom = width/800;
		peoteView.yZoom = height/600;
	}
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
