package;

import haxe.CallStack;
import lime.graphics.RenderContext;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Texture;
import peote.view.TextureData;
import peote.view.TextureFormat;


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
		var textureA = new Texture(w, h, 1, {format:TextureFormat.FLOAT_RGB});
		var textureB = new Texture(w, h, 1, {format:TextureFormat.FLOAT_RGB});
		
		// initialize some random cells into textureB (TODO: let paint into later!)
		textureB.setData( genRandomCellImage(w, h) );
		
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
	
	public static function genRandomCellImage(w:Int, h:Int):TextureData {
		var textureData = new TextureData(w, h, TextureFormat.FLOAT_RGB);
		textureData.clearFloat(0.5);
		//for (x in 0...100)
		for (x in 0...w)
			//for (y in 0...100) 
			for (y in 0...h) 
				if (Math.random() < 0.008)
				{
					textureData.setPixelFloatRGB(x, y, Math.random(), Math.random(), Math.random() );
				}
					
					
					
		return textureData;
	}

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	
	function onRender(c:RenderContext):Void
	{
		// render substeps
		//for (i in 0...9) {
			peoteView.renderToTexture(displayA);
			peoteView.renderToTexture(displayB);
		//}
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
