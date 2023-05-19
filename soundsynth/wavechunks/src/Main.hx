package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;
import peote.view.Texture;

class Main extends Application {
	
	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try	startSample(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------
	
	var peoteView:PeoteView;
	var display:Display;
	var texture:Texture;
	
	var peoteAudio:PeoteAudio;

	
	public function startSample(window:Window) 
	{
		var sampleRate:Int = 441 * 25 * 4;
		var frequency:Int = 300;
		
		// init audiowrapper
		peoteAudio = new PeoteAudio(sampleRate);
		
		
		// init peote view and display
		peoteView = new PeoteView(window);
		display = new Display(0, 0, 441, 25, Color.BLACK);
		peoteView.addDisplay(display);
		
		
		// generate the soundwave by GPU
		SinWave.init(display);
		var sinwave = new SinWave(frequency, 441, 25);
		
		
		// create and render it into texture
		texture = new Texture(441, 25, 1, 4, false, 0, 0, true);
		display.setFramebuffer(texture);	
		
	}

	// ------------------------------------------------------------
	/* 
		We are in onMouseDown because on html5 the AudioContext was not allowed to start.
		It must be resumed (or created) after a user gesture on the page
	*/
	
	override function onMouseDown(x:Float, y:Float, button:lime.ui.MouseButton):Void
	{
		// render and fetch texture data
		peoteView.renderToTexture(display);
		
		// send data to audio
		//peoteAudio.play(texture.readPixelsFloat32(0, 0, 441, 25));
		
		
		// TODO: use into PeoteAudio at what works into SinWave-Sample at now for OpenAL
		
		var timer = new haxe.Timer(990);
		timer.run = () -> {
				peoteAudio.play(texture.readPixelsFloat32(0, 0, 441, 25));
		};
		
	}
	
}
