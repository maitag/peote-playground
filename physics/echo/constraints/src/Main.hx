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

	var mousePin:PinElastic = null;
	
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
			gravity_y: 40, // Force of Gravity on the Y axis. Also available for the X axis.
			iterations: 2 // Sets the number of Physics iterations that will occur each time the World steps.
		});
		

		// ---- CREATE ELEMENTS ----
		//        \o/

		
		var orange = circleProgram.createElement(world, 250, 100, 50, Color.ORANGE, onMove, onRotate, {
			//mass: 4,
			velocity_x:-70,
			velocity_y:-30,
			material: {elasticity: 1.0}
		});
		

		// ---- CREATE CONSTRAINTS ----	
		bodyConstraints = new BodyConstraints();
		
		var green0 = rectProgram.createElement(world, 300,300, 50,50, Color.GREEN2, onMove, {drag_length:0, material: {elasticity: 0.9, gravity_scale:1} });
		var green1 = rectProgram.createElement(world, 300,400, 50,50, Color.GREEN3, onMove, {drag_length:0, material: {elasticity: 0.9, gravity_scale:1} });
		bodyConstraints.add(new DistanceElastic(green0.body, green1.body, 0.3, 0.5));

		var blue = circleProgram.createElement(world, 500, 250, 25, Color.BLUE2, onMove, {drag_length:0, velocity_x:-100, material: {elasticity: 0.9, gravity_scale:35} });
		bodyConstraints.add(new PinElastic(400, 0, blue.body, 0.95, 0.5));
		
		
		var tri0 = circleProgram.createElement(world, 700, 70, 25, Color.YELLOW, onMove, {drag_length:0, velocity_x:-200, material: {elasticity: 1.0, gravity_scale:1} });
		var tri1 = circleProgram.createElement(world, 650, 50, 25, Color.YELLOW, onMove, {drag_length:0, velocity_x:-200, material: {elasticity: 1.0, gravity_scale:1} });
		var tri2 = circleProgram.createElement(world, 750, 50, 25, Color.YELLOW, onMove, {drag_length:0, velocity_x:-200, material: {elasticity: 1.0, gravity_scale:1} });
		bodyConstraints.add(new DistanceElastic(tri0.body, tri1.body, 0.8, 0.7, 50));
		bodyConstraints.add(new DistanceElastic(tri1.body, tri2.body, 0.8, 0.7, 50));
		bodyConstraints.add(new DistanceElastic(tri2.body, tri0.body, 0.8, 0.7, 50));



		// controlled by mouse
		var red = circleProgram.createElement(world, 500, 250, 20, Color.RED2, onMove, {drag_length:0, material: {elasticity: 0.5, gravity_scale:0} });
		mousePin = new PinElastic(100, 100, red.body, 0.9, 0.9, 0.01);
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
