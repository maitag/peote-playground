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

		var buffer = new Buffer<Body>(1024, 1024, true);
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
		
		
		// should this be inside Body.hx constructor :) ?
		
		var blue = world.make({
			mass: 0, // Setting this to zero makes the body unmovable by forces and collisions
			y: 48, // Set the object's Y position below the Circle, so that gravity makes them collide
			elasticity: 0.2,
			shape: {
				type: RECT,
				width: 10,
				height: 10
			}
		});
		
		
		
		
		// 2 testing peote-bodies
		
		var bodyBlue = new Body();
		bodyBlue.color = Color.BLUE;
		bodyBlue.x = 150;
		bodyBlue.y = 0;
		
		buffer.addElement(bodyBlue);
		
		
		
		
		
		var bodyRed = new Body();
		bodyRed.color = Color.RED;
		bodyRed.x = 200;
		bodyRed.y = 200;
		
		buffer.addElement(bodyRed);
		
		
		
		
		// test animation
		bodyBlue.animPosition(150, 0, 150, 300); // x_start, y_start, x_end, y_end
		
		bodyBlue.timePosition(0, 3); // starting at Time 0 ... should need 3 seconds to move to
		
		buffer.updateElement(bodyBlue);
		
		
		peoteView.start();
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	public override function update(deltaTime:Int):Void {
		// for game-logic update
	}

	public override function render(context:lime.graphics.RenderContext):Void
	{
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
