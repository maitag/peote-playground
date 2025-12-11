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
	public static var sampleRate(default, null):Int = 44100;
	
	public static inline function init(?defaultSampleRate:Null<Int>)
	{
		if (context != null) throw("OpenAL already initialized");
		
		device = ALC.openDevice();
		context = ALC.createContext(device);
		sampleRate = (defaultSampleRate != null && sampleRate > 0) ? sampleRate : ALC.getIntegerv(device, ALC.FREQUENCY, 1)[0];
				
		ALC.makeContextCurrent(context);
		ALC.processContext(context);	
	}
	
	
	public static inline function play(data:Float32Array)
	{
		var buffer = AL.createBuffer();
		AL.bufferData(buffer, AL_FORMAT_MONO_FLOAT32,
			lime.utils.Float32Array.fromBytes(data.view.buffer),
			data.view.buffer.length, sampleRate);
		
		var source = AL.createSource();				
		AL.sourcef  (source, AL.PITCH, 1.0);
		AL.sourcef  (source, AL.GAIN, 0.3);
		AL.source3f (source, AL.POSITION, 0.0, 0.0, 0.0); // for first value: -1.0 -> left, 1.0 -> right
		AL.source3f (source, AL.VELOCITY, 0.0, 0.0, 0.0);

		AL.sourcei(source, AL.BUFFER, buffer);
		AL.sourcePlay(source);
	}
}
