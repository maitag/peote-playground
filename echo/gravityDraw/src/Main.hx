package;

import echo.Body;
import echo.data.Types.ForceType;
import echo.math.Vector2;
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
	var cursor:Body;
	
	var canvas:Canvas;
	
	static var MAX_RADIUS:Float = 100;
	
	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);		
		
		// display that shows the texture where is drawed into
		var displayCanvas = new Display(0, 0, 800, 600);
		Canvas.init(displayCanvas);
		peoteView.addDisplay(displayCanvas);
		canvas = new Canvas(800, 600);

		// display draws the pens into the Canvas texture
		var display = new Display(0, 0, 800, 600); // do not give an opaque backgrund-color there!		
		peoteView.addDisplay(display);
		peoteView.addFramebufferDisplay(display); // add also to the hidden RenderList for updating the Framebuffer Textures
		display.renderFramebufferEnabled = true;		
		display.setFramebuffer(Canvas.texture); // texture to render into
		
		Pen.init(display);
		//Circle.init(display);
		
		peoteView.start();
		
		
		// ---- ECHO PHYSICS ----------------
		
		world = Echo.start({
			x:-MAX_RADIUS*3,
			y:-MAX_RADIUS*3,
			width:  800 + MAX_RADIUS*3,
			height: 600 + MAX_RADIUS*3,
			iterations: 1 // number of Physics iterations each time the World steps
		});
		
		
		// create echo bodies				
		var bodies = [];	
		for (i in 0...10) bodies.push( addBody( 10 + Math.random()*10 ) );
		for (i in 0...15) bodies.push( addBody( 20 + Math.random()*15 ) );
		for (i in 0...30) bodies.push( addBody( 30 + Math.random()*20 ) );
		for (i in 0...15) bodies.push( addBody( 40 + Math.random()*15 ) );
		for (i in 0...10) bodies.push( addBody( 50 + Math.random()*10 ) );		
		for (i in 0...5 ) bodies.push( addBody( 60 + Math.random()*20 ) );		
		
		cursor = addBody( 150 );
		bodies.push(cursor);
		
		// listen for collision
		world.listen( bodies, {
			separate: false, // red and blue collides
			enter: function (a, b, c) {
				//trace("Collision Entered"); // at first frame that a collision starts
				a.entity.intersected++;
				b.entity.intersected++;
				//a.entity.color.red = a.entity.color.green = a.entity.color.blue = Std.int(Math.min(0xff, 96 + a.entity.intersected * 16));
				//b.entity.color.red = b.entity.color.green = b.entity.color.blue = Std.int(Math.min(0xff, 96 + b.entity.intersected * 16));
				//a.entity.color = Color.WHITE;
				//b.entity.color = Color.WHITE;
			},
			stay: function (a:Body, b:Body, c) {				
				// let them move to its center of gravity
				var distance:Float = Math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
				var direction:Vector2 =  new Vector2(a.x - b.x, a.y - b.y);
				direction.normalize();
				direction *= Math.pow((a.entity.radius + b.entity.radius - distance), 2) ;				
				a.push(-direction.x / a.mass , -direction.y / a.mass, false, ForceType.VELOCITY);
				b.push(direction.x / b.mass, direction.y / b.mass, false, ForceType.VELOCITY);
			},
			exit: function (a, b) {
				//trace("Collision Exited"); // at first frame that a collision starts
				a.entity.intersected--;
				b.entity.intersected--;				
				//a.entity.color.red = a.entity.color.green = a.entity.color.blue = Std.int(Math.min(0xff, 96 + a.entity.intersected * 16));
				//b.entity.color.red = b.entity.color.green = b.entity.color.blue = Std.int(Math.min(0xff, 96 + b.entity.intersected * 16));				
				//if (a.entity.intersected == 0) a.entity.color = Color.GREY4;
				//if (b.entity.intersected == 0) b.entity.color = Color.GREY4;
			}
		});

	}
	
	public function addBody(radius:Float):Body
	{
		var body:Body = world.make({
				mass: Math.PI * radius * radius,
				kinematic:true,
				max_velocity_length:3000,
				shape: {
					type: CIRCLE,
					radius: radius
				}
		});
		
		setInitialMovement(body);
		
		// connect peote-view graphic element to echos body
		body.entity = new Pen(body.x, body.y, radius, Color.random() | 1);
		body.on_move = onMove.bind(body, _);
		
		return body;
	}
	
	public function onMove(body:Body, x:Float, y:Float)
	{
		if ( (x < -MAX_RADIUS * 3 && body.velocity.x < 0)
			|| (y < -MAX_RADIUS * 3 && body.velocity.y < 0)
			|| (x > 800 + MAX_RADIUS * 3 && body.velocity.x > 0)
			|| (y > 600 + MAX_RADIUS * 3 && body.velocity.y > 0)
		)
		{
			body.velocity.set(0,0);
			setInitialMovement(body);
		}
		else body.entity.update(x, y);
		
	}
	
	public function setInitialMovement(body:Body) {
		
		var x:Float = Math.random() * 800;
		var y:Float = Math.random() * 600;
		var dx:Float = 2.5 - Math.random() * 5;
		var dy:Float = 2.5 - Math.random() * 5;
		
		if (Math.random() > 0.5) {
			if (Math.random() > 0.5) {
				x = -MAX_RADIUS * 3 + 1;
				dx = 10 + Math.random() * 20;
			}
			else {
				x = 800 + MAX_RADIUS * 3 - 1;
				dx = -(10 + Math.random() * 20);
			}
		}
		else {
			if (Math.random() > 0.5) {
				y = -MAX_RADIUS * 3 + 1;
				dy = 10 + Math.random() * 20;
			}
			else {
				y = 600 + MAX_RADIUS * 3 - 1;
				dy = -(10 + Math.random() * 20);
			}
		}
		
		body.x = x;
		body.y = y;

		body.velocity.set(dx, dy);		
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
	public override function onMouseMove (x:Float, y:Float):Void {
		cursor.velocity.set(0,0);
		cursor.x = x;
		cursor.y = y;
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
