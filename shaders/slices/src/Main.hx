package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.Image;

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
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.GREY2);

		peoteView.addDisplay(display);
		
		Load.image ("assets/test0.png", true, function (image:Image) 
		{
			var texture = new Texture(image.width, image.height, 2);
			
			texture.setData(image);
					
			Default.init(display, texture); new Default(0, 0, 150, 100);

			HSlice.init(display, texture); new HSlice(0, 100, 250, 50);
			HSlice.init(display, texture); new HSlice(0, 200, 400, 100);
			HSlice.init(display, texture); new HSlice(0, 300, 300, 300);
			
			HSliceRepeat.init(display, texture); new HSliceRepeat(400, 300, 310, 100);
			
		});
		
		
		peoteView.start();
	}
		
}
