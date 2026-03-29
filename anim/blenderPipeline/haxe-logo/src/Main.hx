package;

import haxe.Timer;
import lime.ui.*;
import peote.view.*;

import assets.Pipeline;

class Main extends lime.app.Application
{
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	var peoteView:PeoteView;
	var buffer:Buffer<ElemAnim>;
	var display:Display;
	var program:Program;
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		display   = new Display(0,0, window.width, window.height, Color.RED1);
		peoteView.addDisplay(display);
		
		buffer  = new Buffer<ElemAnim>(100);
		program = new Program(buffer);
		program.blendEnabled = true;

		display.addProgram(program);

		
		program.setMultiTexture( PipelineTools.loadTextures(Pipeline.sheets) );

		
		ElemAnim.init(buffer, Pipeline.tiles);

		var elem = new ElemAnim(20, 20, "haxeLogo");
		elem.play("sphereRotate", 0, 3);
		Timer.delay( ()->elem.play("sphereToCubic", peoteView.time, 3), 3000);
		Timer.delay( ()->elem.play("cubicRotate"  , peoteView.time, 3), 6000);
		Timer.delay( ()->elem.play("cubicToHaxe"  , peoteView.time, 3), 9000);
		

		// -> don't forget to start peoteViews timer <-
		peoteView.start();
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// override function render(context:lime.graphics.RenderContext):Void {}

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
