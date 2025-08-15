package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

class MainSpawnOnClick extends Application
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
		peoteView = new PeoteView(window, 0x000020ff);

		peoteView.xZoom = window.width/800;
		peoteView.yZoom = window.height/600;

		emitterDisplay = new EmitterDisplay(0, 0, 800, 600);
		peoteView.addDisplay(emitterDisplay);
		
		// time to s t a r t:
		peoteView.start();
	}
	
	public function random(min:Int, max:Int) return min + Std.random(max + 1 - min);
	// ------------------------------------------------------------
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
	override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {
		emitterDisplay.spawn(

			// SUNRAYS, // type (formula)
			random(0, emitterDisplay.maxTypes),

			{
				steps: random(5,50), // timesteps (how often particles spawns)

				// emitter position
				ex: Std.int(x/peoteView.xZoom),
				ey: Std.int(y/peoteView.yZoom),
				// exFunc:(ex, step, index)->{ return ex; },
				// eyFunc:(ey, step, index)->{ return ey; },

				// overall size of a particle
				size: 5,
				// sizeFunc:(size, step, index)->{ return size + step; },

				// how far the particles goes away over time
				sx: random(50,300),
				sy: random(50,300),
				// sxFunc:(sx, step, index)->{ return sx; },
				// syFunc:(sy, step, index)->{ return sy; },

				// color at start and end of movement for spawned particles
				colorStart: Color.YELLOW,
				colorEnd: 0,
				colorStartFunc:(colorStart, step, index)->{ return Color.random(); },
				// colorEndFunc:(colorEnd, step, index)->{ return Color.random(); },

				spawn:random(1,30), // amount of particles what spawn per time-step
				spawnFunc:(spawn, step)->{ return spawn + step*random(-3, 3); }, // to mod spawn in depend of timestep

				delay:random(50,300), // time before next spawn
				delayFunc:(delay, step)->{ return delay + step*random(-3, 3); }, // to mod delay in depend of timestep

				duration:random(100,3000), // how long a particlespawn exist
				durationFunc:(duration, step)->{ return duration + step*random(-3, 3); }, // to mod duration in depend of timestep
			}
		);
	}	
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
