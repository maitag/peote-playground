package;

import haxe.Timer;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.*;

import sierpinski.SierpinskiTriangle;

class MainSierpinski extends Application
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
	
	var triangleDisplay:TriangleDisplay;

	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);

		// ---- custom Display to draw opengl triangles ----
		
		triangleDisplay = new TriangleDisplay(0, 0, window.width, window.height, 0, 4096, 1024);
		
		// triangleDisplay.blendEnabled = true;
		// triangleDisplay.zoom = 2.6;	triangleDisplay.xOffset = -345;	triangleDisplay.yOffset = -850;
		
		peoteView.addDisplay(triangleDisplay);
		

		var triangle = new SierpinskiTriangle(
			 20,580,Color.random(),
			270, 20,Color.random(),
			580,580,Color.random()
		);

		sierpinski(triangle, true);

	}

	public function sierpinski(t:SierpinskiTriangle, addIt:Bool = false) {

		if (t.area < 10) return; // <- stop recursion

		if (addIt) triangleDisplay.addElement(t);

		var alpha:Int = Std.random(256);

		// middle
		Timer.delay(()->{
			sierpinski(new SierpinskiTriangle(
			t.mid1x,t.mid1y,Color.random(alpha),
			t.mid2x,t.mid2y,Color.random(alpha),
			t.mid3x,t.mid3y,Color.random(alpha)
		), true);
		},500);
		
		// corner1
		Timer.delay(()->{
		sierpinski(new SierpinskiTriangle(
			t.mid1x,t.mid1y,Color.random(alpha),
			t.x2,t.y2,Color.random(alpha),
			t.mid2x,t.mid2y,Color.random(alpha)
		), false);
		},1000);
		
		// corner2
		Timer.delay(()->{
			sierpinski(new SierpinskiTriangle(
			t.mid2x,t.mid2y,Color.random(alpha),
			t.mid3x,t.mid3y,Color.random(alpha),
			t.x3,t.y3,Color.random(alpha)
		), false);
		},1500);
	
		// corner3
		Timer.delay(()->{
			sierpinski(new SierpinskiTriangle(
			t.x1,t.y1,Color.random(alpha),
			t.mid1x,t.mid1y,Color.random(alpha),
			t.mid3x,t.mid3y,Color.random(alpha),
		), false);
		},2000);

	}

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	override function onPreloadComplete():Void {
		// access embeded assets from here
	}

	override function update(deltaTime:Int):Void {
		// for game-logic update
	}

	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");		

	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseMove (x:Float, y:Float):Void {}	
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}	
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	// override function onWindowLeave():Void { trace("onWindowLeave"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
	
}
