package audio.web;

// ------------------------------------------------
// ------------------- WebAudio -------------------
// ------------------------------------------------

import haxe.io.Float32Array;
import js.html.audio.*;

class AudioWeb
{
	public static var context(default, null):AudioContext = null;		
	public static var sampleRate(default, null):Int = 44100;
	
	public static inline function init(?defaultSampleRate:Null<Int>)
	{
		if (context != null) throw("WebAudio already initialized");

		if (defaultSampleRate != null) {
			context = new AudioContext({sampleRate: defaultSampleRate});
			sampleRate = defaultSampleRate;
		}
		else {
			context = new AudioContext();
			sampleRate = Std.int(context.sampleRate);
		}
	}

	public static inline function play(data:Float32Array)
	{			
		var buffer = context.createBuffer(1, data.view.buffer.length, sampleRate);
		buffer.copyToChannel( cast data, 0, 0);
		
		var source = context.createBufferSource();
		source.buffer = buffer;
		source.connect(context.destination);
		source.start();
		
	}
}
