package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.*;

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
	var peoteView:PeoteView;
	
	var mouseX:UniformFloat;
	var mouseY:UniformFloat;
	var rotation:UniformFloat;
		
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.BLACK);

		peoteView.addDisplay(display);
		

		mouseX = new UniformFloat("mouseX", 0.0);
		mouseY = new UniformFloat("mouseY", 0.0);
		rotation = new UniformFloat("rotation", 0.0);

		
		Triangle.init( [mouseX], display); 
		var triangle = new Triangle(0, 0, 200, 200);
		
		TriVertex.init( [mouseX], display);
		var triVertex = new TriVertex(200, 200, 200, 200);
		
		TriColored.init( [mouseX], display); 
		var triColored = new TriColored(0, 400, 200, 200);
	

		
		Egg.init("pow(abs(x/0.75),0.5+4.0*mouseX)+pow(abs(y),0.5+4.0*mouseY)", [mouseX, mouseY], display); // https://en.wikipedia.org/wiki/Superellipse
		var egg = new Egg(200, 0, 200, 200);
		
		
		
		Test.init( [mouseX, mouseY, rotation], display); 
		var test = new Test();
		
		

		// Isoscales.init( [mouseX, mouseY, rotation], display); 
		// var isoscales = new Isoscales();
		
		TrapezoidSym.init([], display);
		var trapezoidSym = new TrapezoidSym(600,30);

		

		// FanbladeDevelop.init( [rotation], display);
		// var fanbladeDevelop = new FanbladeDevelop(400, 300, 400, 100, 400, 0, 0);
		
		Fanblade.init( [rotation], display);
		//                           x   y   len   h1   h2  p  r 
		var fanblade = new Fanblade(400, 300, 400, 100, 400, 0, 0);
		
		

		Perspective.init( [mouseX, mouseY, rotation], display);
		var perspective = new Perspective(400, 500, 200, 200,  0.25);

		peoteView.start();
	}
	
	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// ----------------- MOUSE EVENTS ------------------------------
	
	override function onMouseMove (x:Float, y:Float):Void {
		//mx.value = x / window.width;
		
		mouseX.value = x / window.width;
		mouseY.value = y / window.height;
		
		// trace(mouseY.value);
	}

	override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {
		rotation.value += ((deltaY>0) ? 1 : -1 ) * 15.0;
		trace(rotation.value);
	}
	
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
		

	
	// ----------------- KEYBOARD EVENTS ---------------------------
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}	
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	
}
