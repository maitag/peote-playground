package;

import haxe.io.Float32Array;

#if html5 

// ------------------------------------------------
// ------------------- WebAudio -------------------
// ------------------------------------------------

import js.html.audio.*;

class AudioBackend
{
	public static var context:AudioContext = null;
	
	public var buffer(default, null):AudioBuffer;
	public var source(default, null):AudioBufferSourceNode;
	
	public var sampleRate:Int;
	
	public inline function new(sampleRate:Int)
	{
		this.sampleRate = sampleRate;

		if (context == null) context = new AudioContext();
		
		buffer = context.createBuffer(1, sampleRate, sampleRate);
		
	}

	public inline function play(data:Float32Array)
	{		
		
		if (source != null)
		{
			source.stop();
			source.disconnect(context.destination);
		}
		
		source = context.createBufferSource();
		buffer.copyToChannel( cast data, 0, 0);
		source.buffer = buffer;
		source.connect(context.destination);
		source.start();
		
	}
}

#else

// ------------------------------------------------
// ------------------- OpenAL ---------------------
// ------------------------------------------------

import haxe.io.Bytes;
import lime.media.openal.*;

class AudioBackend
{
	public static var device(default, null):ALDevice = null;
	public static var context(default, null):ALContext = null;
	
	public var buffer(default, null):ALBuffer;
	public var source(default, null):ALSource;	
	
	public var sampleRate:Int;
	
	var bufferBytes:Bytes;

	public inline function new(sampleRate:Int)
	{
		this.sampleRate = sampleRate;

		// TODO: check that this is not already created by Lime!
		if (context == null) {
			device = ALC.openDevice();
			context = ALC.createContext(device);
		}
		
		ALC.makeContextCurrent(context);
		ALC.processContext(context);
		
		buffer = AL.createBuffer();
		source = AL.createSource();
		
		bufferBytes = Bytes.alloc(sampleRate << 1);
		
		AL.sourcef  (source, AL.PITCH, 1.0);
		AL.sourcef  (source, AL.GAIN, 1.0);
		AL.source3f (source, AL.POSITION, 0.0, 0.0, 0.0); // for first value: -1.0 -> left, 1.0 -> right
		AL.source3f (source, AL.VELOCITY, 0.0, 0.0, 0.0);
	}
	
	public inline function play(data:Float32Array)
	{
		// convert from Float32 to Int16
		var i:Int = 0; var v:Int;
		for (sample in data) {
			v = Std.int(32767.0 * sample);
			bufferBytes.set(i++, v);
			bufferBytes.set(i++, v >> 8);
		}
		
		AL.bufferData(buffer, AL.FORMAT_MONO16,
			lime.utils.Int16Array.fromBytes(bufferBytes), 
			bufferBytes.length, sampleRate
		);
		
		AL.sourcei(source, AL.BUFFER, buffer);
		AL.sourcePlay(source);
	}
}

#end




// ------------------------------------------------
// ----------- PeoteAudio - Wrapper ---------------
// ------------------------------------------------

@:forward
@:forwardStatics
abstract PeoteAudio(AudioBackend)
{
	public inline function new(sampleRate:Int) 
	{
		this = new AudioBackend(sampleRate);
	}
	
	// MORE HERE to wrap around both
	
}

