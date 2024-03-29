package;

import TurboData.TurboTranslate;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

import utils.Loader;

class HappyBillyBucket extends Application
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

		var buffer = new Buffer<TurboLine>(16384*4, 4096, true);
		var display = new Display(0, 0, window.width, window.height, Color.BLACK);
		var program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);

		
		var filepath = "assets/happybucket.json";
		
		
		Loader.text( filepath,
			function(loaded:Int, size:Int) trace('loading progress ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)'),
			function(errorMsg:String) trace('error $errorMsg'),
			function(json:String) // on load
			{
				// sorry about this little dirty red-knob-hack
				// (all will be more easy to use later by using "turbo-format" lib)				
				var frame = new Array<String>();
				var r = ~/("lines":\s*\[.*?\])/;
				while ( r.match(json) ) {
					//trace("frame:\n", r.matched(1), "\n\n");
					frame.push("{" + r.matched(1) + "}");
					json = r.replace(json, "");
				}
				// ----------------------------------------------------------------
				
				var turboLines = TurboData.decode(frame[3], filepath);

				var size = 640;
				var x = -340;
				var y = -340;
				
				for ( line in turboLines ) {
					
					var start = TurboTranslate.model_to_view_point(line.from, size, x, y);
					var end = TurboTranslate.model_to_view_point(line.to, size, x, y);
					
					var x0 = Std.int(start.x);
					var y0 = Std.int(start.y);
					var x1 = Std.int(end.x);
					var y1 = Std.int(end.y);

					buffer.addElement( new TurboLine(x0, y0, x1, y1, Color.GREEN) );
				}
				
			}			
		);
		
		
	}
	
	
}
