package;

import haxe.Timer;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.*;

import echo.Echo;
import echo.math.Vector2;
import echo.World;
import echo.Body;
import echo.data.Options;

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

	var peoteView:PeoteView;
	var display:Display;

	var rectProgram:RectProgram;
	var circleProgram:CircleProgram;
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);

		display = new Display(0, 0, window.width, window.height);
		peoteView.addDisplay(display);

		
		rectProgram = new RectProgram();
		display.addProgram(rectProgram);

		circleProgram = new CircleProgram();
		display.addProgram(circleProgram);



		// ---- ECHO WORLD ------		

		world = Echo.start({
			width: 64, // Affects the bounds for collision checks.
			height: 64, // Affects the bounds for collision checks.
			gravity_y: 40, // Force of Gravity on the Y axis. Also available for the X axis.
			iterations: 2 // Sets the number of Physics iterations that will occur each time the World steps.
		});
		

		// ---- CREATE ELEMENTS ----		
		//        \o/

		var red = rectProgram.createElement(world, 150, 100, 100, 100, Color.RED3, onMove, onRotate, {
			//mass: 4,
			rotation: 15,
			rotational_velocity:55,
			velocity_x:-100,
			velocity_y:-90,
			material: {
				// elasticity: 0.5
				elasticity: 1.0
			}
		});

		var orange = circleProgram.createElement(world, 350, 100, 150, Color.ORANGE, onMove, onRotate, {
			//mass: 4,
			velocity_x:-100,
			velocity_y:-90,
			material: {
				// elasticity: 0.5
				elasticity: 1.0
			}
		});

		var yellow = rectProgram.createElement(world, 400, 300, 30, 30, Color.YELLOW, onMove);

		
		// let them collide
		
		world.listen(red.body, orange.body, {
			separate: true, // red and blue collides
			enter: (a, b, c) -> trace("Collision Entered"), // at first frame that a collision starts
			//stay: (a, b, c) -> trace("Collision Stayed"), // at frames when the two Bodies are continuing to collide
			exit: (a, b) -> trace("Collision Exited"), // at collision ends
		});

		world.listen(red.body, yellow.body, {
			separate: true, // red and blue collides
			enter: (a, b, c) -> trace("Collision Entered"), // at first frame that a collision starts
			//stay: (a, b, c) -> trace("Collision Stayed"), // at frames when the two Bodies are continuing to collide
			exit: (a, b) -> trace("Collision Exited"), // at collision ends
		});

		world.listen(yellow.body, orange.body, {
			separate: true, // red and blue collides
			enter: (a, b, c) -> trace("Collision Entered"), // at first frame that a collision starts
			//stay: (a, b, c) -> trace("Collision Stayed"), // at frames when the two Bodies are continuing to collide
			exit: (a, b) -> trace("Collision Exited"), // at collision ends
		});

		
	}

	function onMove(body:Body, x:Float, y:Float)
	{	
		if (x == body.last_x && y == body.last_y) return;
		// trace("_onMove", x, y);
		worldBorderorderBOUNCINGCheck(body, x, y);
	}
	
	function onRotate(body:Body, rotation:Float)
	{
		if (rotation == body.last_rotation) return;
		// trace("onRotate", rotation);
	}

	function worldBorderorderBOUNCINGCheck(body:Body, x:Float, y:Float) {
		// --------------- bounce at border ----------------
		if (body.velocity.x < 0) {
			if (x - body.bounds().width/2.0 < 0) {
				body.velocity = new Vector2(-body.velocity.x, body.velocity.y);
			}
		}
		else if (x + body.bounds().width/2.0 > window.width) {
			body.velocity = new Vector2(-body.velocity.x, body.velocity.y);
		}

		if (body.velocity.y < 0) {
			if (y - body.bounds().height/2.0 < 0) {
				body.velocity = new Vector2(body.velocity.x, -body.velocity.y);
			}
		}
		else if (y + body.bounds().height/2.0 > window.height) {
			body.velocity = new Vector2(body.velocity.x, -body.velocity.y);
		}		
	}



	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	public override function update(deltaTime:Int):Void
	{
		world.step(deltaTime / 1000);
		rectProgram.update();
		circleProgram.update();
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
	public override function onWindowResize (width:Int, height:Int):Void {
		display.width = width;
		display.height = height;
		
	}
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
