package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Texture;


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
		var w:Int = 800;
		var h:Int = 600;
		

		peoteView = new PeoteView(window);
		
		
		// textures to render into		
		var textureA = new Texture(w, h);
		var textureB = new Texture(w, h);
		
		// initialize some random cells into textureB (TODO: let paint into later!)
		textureB.setImage( genRandomCellImage(w, h) );
		
		
		// hidden displays that only renders into textures		
		var buffer = new Buffer<ReactionDiffusion>(1); // sharing the same peote-view (vertex) Buffer

		var displayA = ReactionDiffusion.createDisplay(w, h, buffer, textureB); // using textureB as source
		peoteView.addFramebufferDisplay(displayA);
		displayA.setFramebuffer(textureA); // render into -> textureA
		
		
		var displayB = ReactionDiffusion.createDisplay(w, h, buffer, textureA); // using textureA as source
		peoteView.addFramebufferDisplay(displayB);
		displayB.setFramebuffer(textureB); // render into -> textureB
			
		// create peote-view Element into Buffer
		buffer.addElement( new ReactionDiffusion(w, h) );
		
		
		// adding visible display, progam, buffer and one element into to show the actual state over time !
		peoteView.addDisplay(displayB); //<-- for testing only!
		//var display = new Display(0, 0, w, h);
		//peoteView.addDisplay(display);
		// add element what show color gradianted
		
	}
	
	public static function genRandomCellImage(w:Int, h:Int):Image {
		var image = new Image(null, 0, 0, w, h, Color.RED);
		for (x in 0...w)
			for (y in 0...h)
				if (Math.random() < 0.3)
					//image.setPixel32(Std.int(w / 2 - 50 + x), Std.int(h / 2 - 50 + y), Color.random() );
					image.setPixel32(x, y, Color.random() );
					
				//red:   0.5 + Math.random() * 0.02 - 0.01;
				//green: 0.25 + Math.random() * 0.02 - 0.01;
					
					
		return image;
	}

	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// ----------------- MOUSE EVENTS ------------------------------
	
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseMove (x:Float, y:Float):Void {}	
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
	
}
