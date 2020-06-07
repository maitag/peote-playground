package;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

import echo.Echo;

class Main extends lime.app.Application
{
	var peoteView:PeoteView;
	var buffer:Buffer<PhysicSprite>;
	
	public function new() super();
	
	public override function onWindowCreate():Void
	{
		// to get sure into rendercontext
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES: 
				initPeoteView(window); // start sample
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}
		
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	
	public function initPeoteView(window:lime.ui.Window)
	{
		peoteView = new PeoteView(window.context, window.width, window.height);

		buffer = new Buffer<PhysicSprite>(1024, 1024, true);
		var display = new Display(0, 0, window.width, window.height, Color.GREEN);
		var program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);


		
		// ---- ECHO PHYSICS ----------------
		
		var world = Echo.start({
			width: 64, // Affects the bounds for collision checks.
			height: 64, // Affects the bounds for collision checks.
			gravity_y: 20, // Force of Gravity on the Y axis. Also available for the X axis.
			iterations: 2 // Sets the number of Physics iterations that will occur each time the World steps.
		});
		
		
		// 2 testing peote-bodies
		
		var red = new PhysicSprite(buffer, Color.RED, world,
			{
				//mass: 4,
				x: 200,
				y: 10,
				rotation: 10,
				elasticity: 0.2,
				shape: {
					type: RECT,
					width: 50,
					height: 50
				}
			}
		);
		
		var blue = new PhysicSprite(buffer, Color.BLUE, world,
			{
				mass: 0, // static
				x: 10,
				y: 300,
				rotation: 0,
				elasticity: 0.2,
				shape: {
					type: RECT,
					width: 500,
					height: 50
				}
			}
		);
		
		// test animation
		// blue.animPosition(150, 0, 150, 300); // x_start, y_start, x_end, y_end
		// blue.timePosition(0, 3); // starting at Time 0 ... should need 3 seconds to move to
		// buffer.updateElement(blue);
		// peoteView.start();
		
		
		
		world.listen(red.body, blue.body, {
			separate: true, // Setting this to true will cause the Bodies to separate on Collision. This defaults to true
			enter: (a, b, c) -> trace("Collision Entered"), // This callback is called on the first frame that a collision starts
			//stay: (a, b, c) -> trace("Collision Stayed"), // This callback is called on frames when the two Bodies are continuing to collide
			exit: (a, b) -> trace("Collision Exited"), // This callback is called when a collision between the two Bodies ends
		});

		// Set up a Timer to act as an update loop (at 60fps)
		new haxe.Timer(16).run = () -> {
			// Step the World's Physics Simulation forward (at 60fps)
			world.step(16 / 1000);
			// Log the World State in the Console
			//echo.util.Debug.log(world);
		}		
		
		
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	public override function update(deltaTime:Int):Void {
		// for game-logic update
		//trace("update", deltaTime);
	}

	public override function render(context:lime.graphics.RenderContext):Void
	{
		//trace("peote", peoteView.time);
		peoteView.render(); // rendering all Displays -> Programs - Buffer
	}
	
	public override function onWindowResize (width:Int, height:Int):Void
	{
		peoteView.resize(width, height);
	}

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
	
	// public override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// public override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");		

}
