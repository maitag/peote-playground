package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.*;

import echo.Echo;
import echo.World;

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
	
	var world:World;
	
	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);

		var buffer = new Buffer<PhysicSprite>(1024, 1024, true);
		var display = new Display(0, 0, window.width, window.height, Color.GREEN);
		var program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);


		
		// ---- ECHO PHYSICS ----------------
		
		world = Echo.start({
			width: 64, // Affects the bounds for collision checks.
			height: 64, // Affects the bounds for collision checks.
			gravity_y: 20, // Force of Gravity on the Y axis. Also available for the X axis.
			iterations: 2 // Sets the number of Physics iterations that will occur each time the World steps.
		});
		
		
		// create echo bodies
				
		var red = new PhysicSprite(buffer, Color.RED, world,
			{
				//mass: 4,
				x: 200,
				y: 100,
				rotation: 45,
				rotational_velocity:15,
				material: {
					elasticity: 0.5
				},
				shape: {
					type: RECT,
					width: 100,
					height: 100
				}
			}
		);
		
		var blue = new PhysicSprite(buffer, Color.BLUE, world,
			{
				mass: 0, // static
				x: 250,
				y: 300,
				rotation: 0,
				material: {
					elasticity: 0.5
				},
				shape: {
					type: RECT,
					width: 500,
					height: 50
				}
			}
		);
		
		
		// let them collide
		
		world.listen(red.body, blue.body, {
			separate: true, // red and blue collides
			enter: (a, b, c) -> trace("Collision Entered"), // at first frame that a collision starts
			//stay: (a, b, c) -> trace("Collision Stayed"), // at frames when the two Bodies are continuing to collide
			exit: (a, b) -> trace("Collision Exited"), // at collision ends
		});

		
		
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	public override function update(deltaTime:Int):Void
	{
		world.step(deltaTime / 1000);
	}

	// public override function render(context:lime.graphics.RenderContext):Void {}
	// public override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");
	// public override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");	

	// ----------------- MOUSE EVENTS ------------------------------
	// public override function onMouseMove (x:Float, y:Float):Void {}
	// public override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// public override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// public override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// public override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// public override function onTouchStart (touch:lime.ui.Touch):Void {}
	// public override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// public override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	// public override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}
	// public override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	// public override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	// public override function onWindowLeave():Void { trace("onWindowLeave"); }
	// public override function onWindowActivate():Void { trace("onWindowActivate"); }
	// public override function onWindowClose():Void { trace("onWindowClose"); }
	// public override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// public override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// public override function onWindowEnter():Void { trace("onWindowEnter"); }
	// public override function onWindowExpose():Void { trace("onWindowExpose"); }
	// public override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// public override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// public override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// public override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// public override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// public override function onWindowRestore():Void { trace("onWindowRestore"); }
	
}
