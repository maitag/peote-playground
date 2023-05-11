package;

import haxe.io.UInt8Array;
import haxe.io.UInt16Array;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;
import peote.view.Texture;

import js.html.audio.AudioContext;
import js.lib.Float32Array;

@:access(peote.view.Texture)
class Main extends Application {
	var dataGPU:UInt8Array;
	var audio:AudioContext;

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
		SinWave.init(display);
		sinwave = new SinWave(frequency, widthTexture, heightTexture);

		// render it into a texture to use for bufferdata !
		var texture = new Texture(widthTexture, heightTexture);
		display.setFramebuffer(texture);
		peoteView.renderToTexture(display);

		dataGPU = texture.readPixelsUInt8(0, 0, widthTexture, heightTexture);
		trace(dataGPU.length);
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

		var f32Samples = [for (sample in dataGPU) (sample - 128) / 128];
		var channelData = Float32Array.from(f32Samples);

		buffer.copyToChannel(channelData, 0, 0);

		var source = audio.createBufferSource();
		source.buffer = buffer;

		// for debugging gpu wave data
		var wave = Util.makeWavFile(dataGPU.view.buffer, samplerate);
		Util.saveWavFile(wave, 'test-$frequency-hz');

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
