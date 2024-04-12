package;

import haxe.io.UInt8Array;
import haxe.io.Float32Array;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.view.*;

import js.html.audio.AudioContext;
//import js.lib.Float32Array;

@:access(peote.view.Texture)
class MainFloat extends Application {
	
	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample(window)
				catch (_)
					trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------
	
	var dataGPUFloat:Float32Array;

	var audio:AudioContext;

	var sinwave:SinWave; // shader for sinus-wave-generation

	var samplerate:Int;
	var frequency:Int = 300;

	public function startSample(window:Window) {
		var peoteView = new PeoteView(window);

		// frequency = 440; // uncomment for testing glitch

		var widthTexture = 441;
		var heightTexture = 25;

		samplerate = widthTexture * heightTexture * 4;

		var display = new Display(0, 0, widthTexture, heightTexture, Color.BLACK);
		peoteView.addDisplay(display);

		// generate the soundwave by GPU
		SinWave.init(display, true);  // last param is to generate shader for float32 texture
		sinwave = new SinWave(frequency, widthTexture, heightTexture);

		// render it into a texture to use for bufferdata !
		var texture = new Texture(widthTexture, heightTexture, 1, { format: TextureFormat.FLOAT_RGBA });
		display.setFramebuffer(texture);
		peoteView.renderToTexture(display);

		dataGPUFloat = texture.readPixelsFloat32(0, 0, widthTexture, heightTexture);

			
		trace(dataGPUFloat.length);
	}

	override function onMouseDown(x:Float, y:Float, button:lime.ui.MouseButton):Void {
		/* 
			we are in onMouseDown because
			The AudioContext was not allowed to start.
			It must be resumed (or created) after a user gesture on the page
		*/
		if (audio == null) {
			audio = new AudioContext();
		}

		var numChannels = 1;
		var length = samplerate;
		var buffer = audio.createBuffer(numChannels, length, samplerate);

		buffer.copyToChannel( cast(dataGPUFloat, js.lib.Float32Array), 0, 0);

		var source = audio.createBufferSource();
		source.buffer = buffer;

		source.connect(audio.destination);
		source.start();
	}

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// ----------------- MOUSE EVENTS ------------------------------
/*	override function onMouseMove (x:Float, y:Float):Void {
		if (peoteView.isRun) {
			sinwave.freq = 200 + x;
			sinwave.update();
		}
	 */
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
