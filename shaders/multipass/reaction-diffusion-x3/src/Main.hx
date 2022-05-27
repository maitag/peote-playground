package;

import haxe.CallStack;
import lime.graphics.RenderContext;

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
	
	var displayA:Display;
	var displayB:Display;
	
	public function startSample(window:Window)
	{
		var w:Int = window.width;
		var h:Int = window.height;
		

		peoteView = new PeoteView(window);
		
		
		// textures to render into		
		var textureA = new Texture(w, h, 1, 4, false, 0, 0, true );
		var textureB = new Texture(w, h, 1, 4, false, 0, 0, true );
		
		// initialize some random cells into textureB (TODO: let paint into later!)
		textureB.setImage( genRandomCellImage(w, h) );
		
		// hidden displays that only renders into textures		
		var buffer = new Buffer<ReactionDiffusion>(1); // sharing the same peote-view (vertex) Buffer

		displayA = ReactionDiffusion.createDisplay(w, h, buffer, textureB); // using textureB as source
		//peoteView.addFramebufferDisplay(displayA);
		peoteView.setFramebuffer(displayA, textureA); // render into -> textureA
		
		
		displayB = ReactionDiffusion.createDisplay(w, h, buffer, textureA); // using textureA as source
		//peoteView.addFramebufferDisplay(displayB);
		peoteView.setFramebuffer(displayB, textureB); // render into -> textureB
			
		// create peote-view Element into Buffer
		buffer.addElement( new ReactionDiffusion(w, h) );
		
		
		// adding visible display, progam, buffer and one element into to show the actual state over time !
		//peoteView.addDisplay(displayB); //<-- for testing only!
		
		var display = new Display(0, 0, w, h);
		peoteView.addDisplay(display);
		Colored.init(display, textureB, 
			[ Color.BLACK, 0x112236ff, 0x192940ff, 0x216689ff, 0x219aaaff, 0xfffff0ff ],
			[ 0.0,         0.001,      0.01,       0.1,        0.5,        1.0        ]
		);
		// add element what show color gradiand
		var coloredOut = new Colored(w, h);
		
		window.onRender.add(onRender);
	}
	
	public static function genRandomCellImage(w:Int, h:Int):Image {
		var image = new Image(null, 0, 0, w, h, Color.RED);
		for (x in 0...100)
			for (y in 0...100) 
				if (Math.random() < 0.1)
				{
					// TODO
					var c = Color.BLACK;
					c.r = Std.int((0.25 + Math.random() * 0.06 - 0.03) * 255);
					c.g = Std.int((0.5  + Math.random() * 0.06 - 0.03) * 255);
					c.b = Std.int((0.5  + Math.random() * 0.06 - 0.03) * 255);
					image.setPixel32(Std.int(w / 2 - 50 + x), Std.int(h / 2 - 50 + y), c );
					//image.setPixel32(Std.int(w / 2 - 50 + x), Std.int(h / 2 - 50 + y), Color.random() );
				}
					
					
					
		return image;
	}

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	
	function onRender(c:RenderContext):Void
	{
		// render substeps
		for (i in 0...3) {
			peoteView.renderToTexture(displayA);
			peoteView.renderToTexture(displayB);
		}
	}
	

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
