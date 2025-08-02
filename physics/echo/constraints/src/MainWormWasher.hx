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

import echo.BodyConstraints;
import echo.BodyConstraints.DistanceElastic;
import echo.BodyConstraints.PinElastic;

using echo.util.ext.FloatExt;

class MainWormWasher extends Application
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

	var mousePin:PinElastic = null;
	var rotatorPin:PinElastic = null;
	
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
			width: window.width, // Affects the bounds for collision checks.
			height: window.height, // Affects the bounds for collision checks.
			gravity_y: 10, // Force of Gravity on the Y axis. Also available for the X axis.
			iterations: 2 // Sets the number of Physics iterations that will occur each time the World steps.
		});
		

		// ---- CREATE ELEMENTS ----
		//        \o/

		// ---- CREATE CONSTRAINTS ----	
		bodyConstraints = new BodyConstraints();
		
		var rotator = rectProgram.createElement(world, window.width/2, window.height/2, Math.min(window.width,window.height)-30, 30, Color.ORANGE, onMove, onRotate, {
			// mass: 0,
			rotational_velocity:-50,
			material: {
				gravity_scale:0,
				elasticity: 0.2
			}
		});
		rotatorPin = new PinElastic(  window.width/2, window.height/2, rotator.body, 0.9, 0.9, 0);
		bodyConstraints.add(rotatorPin);

		for (j in 0...9) { var y = 20 + j * 30;
			for (i in 0...5) { var x = 10 + i * 140;
				var color = Color.random(255);
				var w0 = circleProgram.createElement(world,     x, y, 10, color, onMove, {max_velocity_x:800, max_velocity_y:800,drag_length:0, material: {elasticity: 0.2, gravity_scale:1} });
				var w1 = circleProgram.createElement(world, x+=15, y, 10, color, onMove, {max_velocity_x:800, max_velocity_y:800,drag_length:0, material: {elasticity: 0.2, gravity_scale:1} });
				var w2 = circleProgram.createElement(world, x+=15, y, 10, color, onMove, {max_velocity_x:800, max_velocity_y:800,drag_length:0, material: {elasticity: 0.2, gravity_scale:1} });
				var w3 = circleProgram.createElement(world, x+=15, y, 10, color, onMove, {max_velocity_x:800, max_velocity_y:800,drag_length:0, material: {elasticity: 0.2, gravity_scale:1} });
				var w4 = circleProgram.createElement(world, x+=15, y, 10, color, onMove, {max_velocity_x:800, max_velocity_y:800,drag_length:0, material: {elasticity: 0.2, gravity_scale:1} });
				var w5 = circleProgram.createElement(world, x+=15, y, 10, color, onMove, {max_velocity_x:800, max_velocity_y:800,drag_length:0, material: {elasticity: 0.2, gravity_scale:1} });
				var w6 = circleProgram.createElement(world, x+=15, y, 10, color, onMove, {max_velocity_x:800, max_velocity_y:800,drag_length:0, material: {elasticity: 0.2, gravity_scale:1} });
				var w7 = circleProgram.createElement(world, x+=15, y, 10, color, onMove, {max_velocity_x:800, max_velocity_y:800,drag_length:0, material: {elasticity: 0.2, gravity_scale:1} });
				w0.body.layer_mask = w2.body.layer_mask = w4.body.layer_mask = w6.body.layer_mask = 1;
				w1.body.layer_mask = w3.body.layer_mask = w5.body.layer_mask = w7.body.layer_mask = 2;
				w0.body.layers = w2.body.layers = w4.body.layers = w6.body.layers = 1;
				w1.body.layers = w3.body.layers = w5.body.layers = w7.body.layers = 2;
				bodyConstraints.add(new DistanceElastic(w0.body, w1.body, 0.7, 0.8));
				bodyConstraints.add(new DistanceElastic(w1.body, w2.body, 0.7, 0.8));
				bodyConstraints.add(new DistanceElastic(w2.body, w3.body, 0.7, 0.8));
				bodyConstraints.add(new DistanceElastic(w3.body, w4.body, 0.7, 0.8));
				bodyConstraints.add(new DistanceElastic(w4.body, w5.body, 0.7, 0.8));
				bodyConstraints.add(new DistanceElastic(w5.body, w6.body, 0.7, 0.8));
				bodyConstraints.add(new DistanceElastic(w6.body, w7.body, 0.7, 0.8));
			}
		}

		var green = circleProgram.createElement(world, 90, window.height-100, 70, Color.GREEN3, onMove, {drag_length:0, material: {elasticity: 0.1, gravity_scale:0} });
		var blue = circleProgram.createElement(world, window.width-100, window.height-100, 70, Color.BLUE3, onMove, {drag_length:0, material: {elasticity: 0.1, gravity_scale:0} });
		
		// controlled by mouse
		var red = circleProgram.createElement(world, 700, 100, 20, Color.RED2, onMove, {drag_length:0, material: {elasticity: 0.1, gravity_scale:0} });
		// red.body.layer_mask = 3;
		// red.body.layers = 3;
		mousePin = new PinElastic(100, 100, red.body, 0.9, 0.9, 0);
		bodyConstraints.add(mousePin);

		// let them ALL collide
		world.listen();

		
	}

	var bodyConstraints:BodyConstraints;
	
	var isUpdate=true;
	public override function update(deltaTime:Int):Void
	{
		if (!isUpdate) return;
		
		// -------- collosion world step -----------	
		world.step(deltaTime / 1000, bodyConstraints);

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
	public override function onMouseMove (x:Float, y:Float):Void {
		if (mousePin!=null) {
			mousePin.bp.x = x;
			mousePin.bp.y = y;
		}
	}
	// public override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// public override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// public override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// public override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// public override function onTouchStart (touch:lime.ui.Touch):Void {}
	// public override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// public override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	public override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		switch (keyCode) {
			case SPACE: isUpdate = !isUpdate;
			default:
		}
	}
	// public override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	/*
	public override function onWindowResize (width:Int, height:Int):Void {
		display.width = width;
		display.height = height;
		isUpdate = false;
		for (body in world.members) {
			if (body.x - body.bounds().width/2.0 < 0) body.x = body.bounds().width/2.0;
			else if (body.x + body.bounds().width/2.0 > width) body.x = width - body.bounds().width/2.0;
	
			if (body.y - body.bounds().height/2.0 < 0) body.y = body.bounds().height/2.0;
			else if (body.y + body.bounds().height/2.0 > height) body.y = height - body.bounds().height/2.0;
		}

		rectProgram.update();
		circleProgram.update();
		
		// prevents the update deltaTime to be such as large as it needs to resize the Window!!!!!
		Timer.delay(()->{isUpdate=true;},10);
	}*/
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
