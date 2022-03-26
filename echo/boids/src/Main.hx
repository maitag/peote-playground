package;

import echo.Body;
import echo.data.Types.ForceType;
import echo.math.Vector2;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

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
	
	var red:Circle;
	var blue:Circle;
	
	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);

		var buffer = new Buffer<Circle>(1024, 1024, true);
		var display = new Display(0, 0, window.width, window.height, Color.GREEN);
		
		var program = new Program(buffer);
		program.injectIntoFragmentShader( Circle.fShader );
		program.discardAtAlpha(0.0);

		peoteView.addDisplay(display);
		display.addProgram(program);


		
		// ---- ECHO PHYSICS ----------------
		
		world = Echo.start({
			width: 64, // Affects the bounds for collision checks.
			height: 64, // Affects the bounds for collision checks.
			//gravity_y: 20, // Force of Gravity on the Y axis. Also available for the X axis.
			iterations: 2 // Sets the number of Physics iterations that will occur each time the World steps.
		});
		
		
		// create echo bodies
				
		red = new Circle(buffer, Color.GREY4, world,
			{
				mass: Math.PI*100*100,
				x: 80,
				y: 60,
				//material: {
					//elasticity: 0.5
				//},
				shape: {
					type: CIRCLE,
					radius: 100
				}
			}
		);
		
		blue = new Circle(buffer, Color.GREY4, world,
			{
				mass: Math.PI*50*50,
				x: 60,
				y: 170,
				//material: {
					//elasticity: 0.5
				//},
				shape: {
					type: CIRCLE,
					radius: 50
				}
			}
		);
		
		
		
		// let them collide
		
		world.listen(red.body, blue.body, {
			separate: false, // red and blue collides
			enter: function (a, b, c) {
				//trace("Collision Entered"); // at first frame that a collision starts
				a.sprite.color = Color.RED;
				b.sprite.color = Color.RED;
			},
			//stay: (a, b, c) -> trace("Collision Stayed", c[0].overlap/(a.sprite.radius + b.sprite.radius)), // at frames when the two Bodies are continuing to collide
			stay: function (a:Body, b:Body, c) {
				var distance:Float = Math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
				//trace(distance);
				//b.push((a.x-b.x)*0.01,(a.y-b.y)*0.01, false, ForceType.VELOCITY);
				var direction:Vector2 =  new Vector2(a.x - b.x, a.y - b.y);
				direction.normalize();
				//direction *= Math.min(1000, 1000/(distance*distance));
				direction *= Math.min( 5000, Math.pow((a.sprite.radius + b.sprite.radius - distance)*2, 2) );
				//trace(direction.x);
				a.push(-direction.x / a.mass , -direction.y / a.mass, false, ForceType.VELOCITY);
				b.push(direction.x / b.mass, direction.y / b.mass, false, ForceType.VELOCITY);
			},
			exit: function (a, b) {
				//trace("Collision Exited"); // at first frame that a collision starts
				a.sprite.color = Color.GREY4;
				b.sprite.color = Color.GREY4;
			}
		});

		//blue.body.push(10,0,false,ForceType.VELOCITY);
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
		red.body.x = x;
		red.body.y = y;
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
