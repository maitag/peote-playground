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
	var circleProgram:CircleProgram;
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);

		display = new Display(0, 0, window.width, window.height, Color.GREEN);
		peoteView.addDisplay(display);
		
		circleProgram = new CircleProgram();
		display.addProgram(circleProgram);



		// ---- ECHO WORLD ------		

		world = Echo.start({
			width: 64, // Affects the bounds for collision checks.
			height: 64, // Affects the bounds for collision checks.
			gravity_y: 40, // Force of Gravity on the Y axis. Also available for the X axis.
			iterations: 2 // Sets the number of Physics iterations that will occur each time the World steps.
		});
		

		// ---- ECHO BODIES ------		
		//        \o/
		var body = world.make({
			//mass: 4,
			x: 150,
			y: 100,
			rotation: 15,
			rotational_velocity:55,
			velocity_x:-100,
			velocity_y:-90,
			material: {
				// elasticity: 0.5
				elasticity: 1.0
			},
			shape: {
				type: RECT,
				width: 100,
				height: 100
			}
		});

		var red = new Circle(body, 100, 100, Color.RED);
		circleProgram.addElement(red);

		if (body.mass != 0) {
			body.on_move = onMove.bind(body, red);
			body.on_rotate = onRotate.bind(body, red);
		}

		body = world.make({
			//mass: 4,
			x: 350,
			y: 100,
			rotation: 15,
			rotational_velocity:55,
			velocity_x:-100,
			velocity_y:-90,
			material: {
				// elasticity: 0.5
				elasticity: 1.0
			},
			shape: {
				type: RECT,
				width: 100,
				height: 100
			}
		});

		var orange = new Circle(body, 100, 100, Color.ORANGE);
		circleProgram.addElement(orange);

		if (body.mass != 0) {
			body.on_move = onMove.bind(body, orange);
			body.on_rotate = onRotate.bind(body, orange);
		}


		// Timer.delay(()->{red.body.x = 200;},1000);

		
		
		// let them collide
		/*
		world.listen(red.body, blue.body, {
			separate: true, // red and blue collides
			enter: (a, b, c) -> trace("Collision Entered"), // at first frame that a collision starts
			//stay: (a, b, c) -> trace("Collision Stayed"), // at frames when the two Bodies are continuing to collide
			exit: (a, b) -> trace("Collision Exited"), // at collision ends
		});

		*/
	}

	function onMove(body:Body, element:XYR_Interface, x:Float, y:Float)
	{	
		if (x == body.last_x && y == body.last_y) return;

		// trace("_onMove", x, y);
		worldBorderorderBOUNCINGCheck(body, x, y);

		// update element position
		element.x = body.x;
		element.y = body.y;
	}
	
	function onRotate(body:Body, element:XYR_Interface, rotation:Float)
	{
		if (rotation == body.last_rotation) return;

		// trace("onRotate", rotation);
		element.r = rotation;
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
