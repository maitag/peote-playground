package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;


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
	
	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);

		var colorbandDisplay = new ColorbandDisplay(0, 0, 800, 600);
		peoteView.addDisplay(colorbandDisplay);
		
		
		var colorband:Colorband = [
			{ color:Color.BLACK, size:130, interpolate:{start:0.8} }, // start will be 80% smooth and end is 1.0 (full smooth)
			{ color:Color.GREY4, size:110, interpolate:{end  :0.5} }, // end will be half smooth and start is 1.0 (full smooth)
			{ color:Color.RED  , size:140, interpolate:{start:0.8, end:0.7} }, // start and end is smooth interpolation
			{ color:Color.YELLOW,size:120, interpolate:Interpolate.SMOOTH }, // this is default and sets start and end to 1.0 (full smooth)
			{ color:Color.GREEN, size:125 ,interpolate:Interpolate.LINEAR }, // sets start and end to 0.0 (linear)
			{ color:Color.BLUE , size:142, interpolate:0.5 }, // sets start and end to 0.5 (half smooth)
			{ color:Color.WHITE }
		];
		colorbandDisplay.create(colorband, 0, 100);
			
/*
		var colorband:Colorband = [
			{ color:Color.BLACK },
			{ color:Color.GREY4 },
			{ color:Color.RED   },
			{ color:Color.YELLOW},
			{ color:Color.GREEN },
			{ color:Color.BLUE  },
			{ color:Color.WHITE }
		];
		
		// testing smooth VERSUS linear interpolation
		
		colorbandDisplay.create(colorband, 0, 100, 120, Interpolate.SMOOTH);
		colorbandDisplay.create(colorband, 101, 100, 120, Interpolate.LINEAR);
*/		
		
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	//override function update(deltaTime:Int):Void {
		// for game-logic update
	//}

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
