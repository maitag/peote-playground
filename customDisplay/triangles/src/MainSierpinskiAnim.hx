package;

import haxe.Timer;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.*;

import sierpinski.SierpinskiTriangle;

class MainSierpinskiAnim extends Application
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
	var peoteView:PeoteView;
	var triangleDisplay:TriangleDisplay;
	var triangles = new Array<SierpinskiTriangle>();

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);

		// ---- custom Display to draw opengl triangles ----
		
		triangleDisplay = new TriangleDisplay(0, 0, window.width, window.height, 0, 4096, 1024);
		
		// triangleDisplay.blendEnabled = true;
		// triangleDisplay.zoom = 2.6;	triangleDisplay.xOffset = -345;	triangleDisplay.yOffset = -850;
		
		peoteView.addDisplay(triangleDisplay);
		
		// create elements
		sierpinski(new SierpinskiTriangle(
			20,580,Color.random(),
		   270, 20,Color.random(),
		   580,580,Color.random()
	 	), true, true);

		trace('$index triangles was created');

		onUpdate.add(_update);
		peoteView.start();

	}

	var index:Int = 0;
	public function sierpinski(t:SierpinskiTriangle, visible:Bool = false, create:Bool = false, depth:Int = 0) {
		
		if (++depth > 7) return; // <- stop recursion

		if (visible) {
			if (create) {
				triangleDisplay.addElement(t);
				triangles.push(t);
			}
			else {
				var e = triangles[index];
				e.x1 = t.x1; e.x2 = t.x2; e.x3 = t.x3;
				e.y1 = t.y1; e.y2 = t.y2; e.y3 = t.y3;
				// e.c1 = t.c1; e.c2 = t.c2; e.c3 = t.c3;
				//triangleDisplay.updateElement(e);
			}
			index++;
		}
		var alpha:Int = Std.random(256);

		// middle
		var d1 = 0.5 + Math.sin(peoteView.time*(0.5+index*0.0005)+1+index)*0.05;
		var d2 = 0.5 + Math.sin(peoteView.time*(0.5+index*0.0005)+2+index)*0.05;
		var d3 = 0.5 + Math.sin(peoteView.time*(0.5+index*0.0005)+3+index)*0.05;
		sierpinski(new SierpinskiTriangle(			
			t.delta1x(d1),t.delta1y(d1),Color.random(alpha), // t.mid1x,t.mid1y,Color.random(alpha),
			t.delta2x(d2),t.delta2y(d2),Color.random(alpha), // t.mid2x,t.mid2y,Color.random(alpha),
			t.delta3x(d2),t.delta3y(d2),Color.random(alpha), // t.mid3x,t.mid3y,Color.random(alpha)
		), true, create, depth);
		
		// corner1
		sierpinski(new SierpinskiTriangle(			
			t.delta1x(d1),t.delta1y(d1),Color.random(alpha), // t.mid1x,t.mid1y,Color.random(alpha),
			t.x2,t.y2,Color.random(alpha),
			t.delta2x(d2),t.delta2y(d2),Color.random(alpha), // t.mid2x,t.mid2y,Color.random(alpha)
		), false, create, depth);
		
		// corner2
		sierpinski(new SierpinskiTriangle(
			t.delta2x(d2),t.delta2y(d2),Color.random(alpha), // t.mid2x,t.mid2y,Color.random(alpha),
			t.delta3x(d2),t.delta3y(d2),Color.random(alpha), // t.mid3x,t.mid3y,Color.random(alpha),
			t.x3,t.y3,Color.random(alpha)
		), false, create, depth);
	
		// corner3
		sierpinski(new SierpinskiTriangle(
			t.x1,t.y1,Color.random(alpha),
			t.delta1x(d1),t.delta1y(d1),Color.random(alpha), // t.mid1x,t.mid1y,Color.random(alpha),
			t.delta3x(d2),t.delta3y(d2),Color.random(alpha), // t.mid3x,t.mid3y,Color.random(alpha),
		), false, create, depth);
	}

	
	function _update(deltaTime:Int):Void {
		index = 0;
		var offx2 = Math.sin(peoteView.time*0.5)*200;
		var offy2 = Math.sin(peoteView.time*0.5+2)*50;
		// update elements
		sierpinski(new SierpinskiTriangle(
			20,580,Color.random(),
		//    270, 20,Color.random(),
		   270+offx2, 50+offy2,Color.random(),
		   580,580,Color.random()
	 	), true, false);

		triangleDisplay.update();
	}	
	
	
		
	
	
	
	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	


	// override function update(deltaTime:Int):Void {}

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
