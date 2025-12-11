package audio.web;

// ------------------------------------------------
// ------------------- WebAudio -------------------
// ------------------------------------------------

import haxe.io.Float32Array;
import js.html.audio.*;

class AudioWeb
{
	public static var context:AudioContext = null;
	
	public var buffer(default, null):AudioBuffer;
	public var source(default, null):AudioBufferSourceNode;
	
	public var sampleRate:Int;
	
	public inline function new(sampleRate:Int)
	{
		this.sampleRate = sampleRate;

		if (context == null) context = new AudioContext({sampleRate: sampleRate});
		
		buffer = context.createBuffer(1, sampleRate*10, sampleRate); // max 10 seconds
		
	}

	public inline function play(data:Float32Array)
	{		
		// to prevent from playing parallele
		/*if (source != null)
		{
			source.stop();
			source.disconnect(context.destination);
		}*/
		
		source = context.createBufferSource();
		
		buffer = context.createBuffer(1, data.view.buffer.length, sampleRate);
		buffer.copyToChannel( cast data, 0, 0);

		source.buffer = buffer;
		source.connect(context.destination);
		source.start();
		
	}
}
