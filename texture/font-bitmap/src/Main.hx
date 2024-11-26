package;

import haxe.Timer;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

class Main extends Application {

	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------

	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.BLUE3);
		peoteView.addDisplay(display);


		// ------- create the font-(texture!)-data -------
		var bmFont = new BMFontData(BMFontFull.data);

		// the BMFontSimple contains lesser letter-data:
		// var bmFont = new BMFontData(BMFontSimple.data, BMFontSimple.ranges);



		// ------- create a new BMFontProgram ---------
		var bmFontProgram = new BMFontProgram(bmFont, {
			fgColor:Color.YELLOW,
			bgColor:Color.RED1,
			letterSpace:0,
			lineSpace:1
		});

		display.addProgram(bmFontProgram);


		// -------- FonT-Fun here -----------

		// add some elements to test out:
		bmFontProgram.buff.addElement( new BMFontProgram.Glyph(0  , 0, 100, 100, Color.YELLOW, 0, bmFont.getTile(65) ) );
		bmFontProgram.buff.addElement( new BMFontProgram.Glyph(0  , 100, 100, 100, Color.YELLOW, 0, bmFont.getTile(53) ) );

		// error -> out of charCode-range by using BMFontSimple
		bmFontProgram.buff.addElement( new BMFontProgram.Glyph(100, 0, 100, 100, Color.YELLOW, Color.GREEN2, bmFont.getTile(127)) );

		// error -> out of charCode-range
		// bmFontProgram.buff.addElement( new BMFontProgram.Glyph(200, 0, 100, 100, Color.YELLOW, Color.RED2, bmFont.getTile(128)) );
		







		// TODO next Time:

		/*
		// create a text-instance
		var text1:BMText = bmFontProgram.add(100, 10, "hello world\nHALLO WELT", {
			fgColor:Color.GREEN3,
			letterSpace:2,
			lineSpace:3
		});

		haxe.Timer.delay( ()->{
			bmFontProgram.remove(text1);
		}, 3000);
		*/

	}











	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------

	// override function update(deltaTime:Int):Void {}

	// override function onPreloadComplete():Void {}
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
