package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.media.openal.AL;
import lime.media.openal.ALC;
import lime.utils.Int16Array;

import peote.view.PeoteView;
import peote.view.Display;
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
	
	var sinwave:SinWave; // shader for sinus-wave-generation
	
	var srate:Int = 44100; // sample rate
	var freq:Int  = 300;   // frequence
	
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.BLACK);

		peoteView.addDisplay(display);
		
		// generate the soundwave by GPU
		SinWave.init(display);
		sinwave = new SinWave(freq, srate);
		
		// TODO: render it into a texture to use for bufferdata !
		
		
		
		// ----- play the soundwave by OpenAL --------
		
		var device = ALC.openDevice();
		var context = ALC.createContext(device);
		ALC.makeContextCurrent(context);
		ALC.processContext(context);
		
		var buffer = AL.createBuffer();
		
		var data = new Int16Array(srate);
		
		// generate the soundwave by CPU
		for (i in 0...srate) 
		{
			var value:Int = Std.int( Math.sin( (i * Math.PI * 2  * freq) / srate) * 0x7FFF );
			data[i] = value; 
		}

		AL.bufferData(buffer, AL.FORMAT_MONO16, data, data.byteLength, srate);
		
		var source = AL.createSource();
		
		//AL.sourcei  (source, AL.LOOPING, AL.TRUE);
		AL.sourcef  (source, AL.PITCH, 1.0);
		AL.sourcef  (source, AL.GAIN, 1.0);
		AL.source3f (source, AL.POSITION, 0.0, 0.0, 0.0); // for first value: -1.0 -> left, 1.0 -> right
		AL.source3f (source, AL.VELOCITY, 0.0, 0.0, 0.0);

		AL.sourcei (source, AL.BUFFER, buffer);
		
		// todo:
		// AL.sourceQueueBuffer(source, buffer);		
		
		AL.sourcePlay(source);
		
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
	}
*/	
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
	
}
