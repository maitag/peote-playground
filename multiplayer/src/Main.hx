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

		// TODO: 1 )bind peote-ui
		//       2 )bind peote-net
		
		var buffer = new Buffer<Sprite>(4, 4, true);
		var display = new Display(10, 10, window.width - 20, window.height - 20, Color.GREEN);
		var program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);

		var sprite = new Sprite();
		buffer.addElement(sprite);
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	override function update(deltaTime:Int):Void {
		// for game-logic update
	}

	
}
