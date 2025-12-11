package audio.openAL;

// ------------------------------------------------
// ------------------- OpenAL ---------------------
// ------------------------------------------------

import haxe.io.Bytes;
import haxe.io.Float32Array;
import lime.media.openal.*;

class AudioOpenAL
{
	public static inline var AL_FORMAT_MONO_FLOAT32 = 0x10010;

	public static var device(default, null):ALDevice = null;
	public static var context(default, null):ALContext = null;
	
	public var buffer(default, null):ALBuffer;
	public var source(default, null):ALSource;	
	
	public var sampleRate:Int;
	
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
		AL.sourcef  (source, AL.PITCH, 1.0);
		AL.sourcef  (source, AL.GAIN, 0.3);
		AL.source3f (source, AL.POSITION, 0.0, 0.0, 0.0); // for first value: -1.0 -> left, 1.0 -> right
		AL.source3f (source, AL.VELOCITY, 0.0, 0.0, 0.0);
	}
	
	
	public inline function play(data:Float32Array)
	{
		AL.bufferData(buffer, AL_FORMAT_MONO_FLOAT32,
			lime.utils.Float32Array.fromBytes(data.view.buffer),
			data.view.buffer.length, sampleRate);
		
		AL.sourcei(source, AL.BUFFER, buffer);
		AL.sourcePlay(source);
	}
}
