package;

import haxe.Timer;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.*;

import echo.Echo;
import echo.World;
import echo.Body;
import echo.math.Vector2;
import echo.data.Types.ForceType;
import echo.util.verlet.Constraints.DistanceConstraint;
import echo.util.verlet.Composite;

using echo.util.ext.FloatExt;

class MainComposite extends Application
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
			material: {elasticity: 1.1}
		});

		var orange = circleProgram.createElement(world, 350, 100, 150, Color.ORANGE, onMove, onRotate, {
			//mass: 4,
			velocity_x:-100,
			velocity_y:-90,
			material: {elasticity: 1.0}
		});

		var yellow = rectProgram.createElement(world, 400, 300, 30, 30, Color.YELLOW, onMove, {material: {elasticity: 0.5}});

		
		// let them collide		
		world.listen(red.body, orange.body, {
			separate: true, // red and blue collides
			// enter: (a, b, c) -> trace("Collision Entered"), // at first frame that a collision starts
			//stay: (a, b, c) -> trace("Collision Stayed"), // at frames when the two Bodies are continuing to collide
			// exit: (a, b) -> trace("Collision Exited"), // at collision ends
		});
		world.listen(red.body, yellow.body, {separate: true});
		world.listen(yellow.body, orange.body, {separate: true});
		
		// WHY THIS NOT WORKS instead ?
		// world.listen([red.body, yellow.body, orange.body], {separate: true});

		// ---- CREATE CONSTRAINTS ----	
		
		test0 = circleProgram.createElement(world, 510, 200, 30, Color.GREEN2, onMove, {drag_length:0, material: {elasticity: 0.1}, velocity_x:-100});
		test1 = circleProgram.createElement(world, 500, 300, 30, Color.GREEN3, onMove, {drag_length:0, material: {elasticity: 0.1} });

		composite = new Composite();
		composite.add_dot(test0.x, test0.y);
		composite.add_dot(test1.x, test1.y);
		composite.add_constraint(new DistanceConstraint(composite.dots[0], composite.dots[1], 0.98, 120));

		// let them collide to all others	
		world.listen(test0.body, orange.body, {separate: true});
		world.listen(test1.body, orange.body, {separate: true});
		world.listen(test0.body, red.body, {separate: true});
		world.listen(test1.body, red.body, {separate: true});
		world.listen(test0.body, orange.body, {separate: true});
		world.listen(test1.body, orange.body, {separate: true});
		world.listen(test0.body, yellow.body, {separate: true});
		world.listen(test1.body, yellow.body, {separate: true});
	}

	var composite:Composite;
	var test0:Circle;
	var test1:Circle;

	public override function update(deltaTime:Int):Void
	{
		// ---- calculate constraints ------
		composite.dots[0].x = test0.body.x;
		composite.dots[0].y = test0.body.y;
		composite.dots[1].x = test1.body.x;
		composite.dots[1].y = test1.body.y;

		var iterations:Int = 3;
		for (i in 0...iterations) {
			for (c in composite.constraints) {
				if (c.active) c.step(1/iterations);
			}
		}

		// var normal = test0.body.get_position() -  test1.body.get_position(); // Math.abs(120 - normal.length);

		// add constraint velocity
		var m:Float = 20;
		var x0=(composite.dots[0].x-test0.body.x)*m;
		var y0=(composite.dots[0].y-test0.body.y)*m;
		var x1=(composite.dots[1].x-test1.body.x)*m;
		var y1=(composite.dots[1].y-test1.body.y)*m;
		test0.body.push(x0, y0, ForceType.VELOCITY);
		test1.body.push(x1, y1, ForceType.VELOCITY);


		// -------- collosion world step -----------
		
		world.step(deltaTime / 1000);

		// ---- remove a part of the constraint velocity ----
		var n:Float = 0.25;
		test0.body.push(-x0 * n, -y0 * n, ForceType.VELOCITY);
		test1.body.push(-x1 * n, -y1 * n, ForceType.VELOCITY);

		// ---- update all graphic elements -----
		rectProgram.update();
		circleProgram.update();
	}
	
	
	function onMove(body:Body, x:Float, y:Float)
	{	
		// if (x == body.last_x && y == body.last_y) return;
		if (!body.moved()) return;
		// trace("_onMove", x, y);
		worldBorderorderBOUNCINGCheck(body, x, y);
	}
	
	function onRotate(body:Body, rotation:Float)
	{
		// if (rotation == body.last_rotation) return;
		if (body.rotation.equals(body.last_rotation, 0.001)) return;
		// trace("onRotate", rotation);
	}

	function worldBorderorderBOUNCINGCheck(body:Body, x:Float, y:Float) {
		// --------------- bounce at border ----------------
		if (body.velocity.x < 0) {
			if (x - body.bounds().width/2.0 < 0) {
				body.velocity = new Vector2(-body.velocity.x, body.velocity.y);
				body.x = body.bounds().width/2.0;
			}
		}
		else if (x + body.bounds().width/2.0 > window.width) {
			body.velocity = new Vector2(-body.velocity.x, body.velocity.y);
			body.x = window.width - body.bounds().width/2.0;
		}

		if (body.velocity.y < 0) {
			if (y - body.bounds().height/2.0 < 0) {
				body.velocity = new Vector2(body.velocity.x, -body.velocity.y);
				body.y = body.bounds().height/2.0;
			}
		}
		else if (y + body.bounds().height/2.0 > window.height) {
			body.velocity = new Vector2(body.velocity.x, -body.velocity.y);
			body.y = window.height - body.bounds().height/2.0;
		}		
	}



	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

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
