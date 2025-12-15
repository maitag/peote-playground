package audio.openAL;

// ------------------------------------------------
// ------------------- OpenAL ---------------------
// ------------------------------------------------

import haxe.io.Bytes;
import haxe.io.Float32Array;

import lime.media.openal.ALDevice;
import lime.media.openal.ALContext;
import lime.media.openal.ALC;

class AudioOpenAL
{
	public static inline var AL_FORMAT_MONO_FLOAT32 = 0x10010;

	public static var device(default, null):ALDevice = null;

	public static var context(default, null):ALContext = null;		
	public static var sampleRate(default, null):Int = 44100;
	
	public static inline function init(defaultSampleRate:Int = 0)
	{
		if (context != null) throw("OpenAL already initialized");
		
		device = ALC.openDevice();
		context = ALC.createContext(device);
		sampleRate = (defaultSampleRate > 0) ? defaultSampleRate : ALC.getIntegerv(device, ALC.FREQUENCY, 1)[0];
				
		ALC.makeContextCurrent(context);
		ALC.processContext(context);	
	}
	
	/*
	// creates buffer and source on the fly for playing

	// did not play parallele on hl-target if the source var is local inside the play() function !!!
	static var source:ALSource;	
	public static function play(data:Float32Array)
	{
		var buffer = AL.createBuffer();
		
		AL.bufferData(buffer, AL_FORMAT_MONO_FLOAT32,
			lime.utils.Float32Array.fromBytes(data.view.buffer),
			data.view.buffer.length, sampleRate);
		
		
		source = AL.createSource();
		
		AL.sourcef  (source, AL.PITCH, 1.0);
		AL.sourcef  (source, AL.GAIN, 1.0);
		AL.source3f (source, AL.POSITION, 0.0, 0.0, 0.0); // for first value: -1.0 -> left, 1.0 -> right
		AL.source3f (source, AL.VELOCITY, 0.0, 0.0, 0.0);

		// AL.sourcei(source, AL.SOURCE_TYPE, AL.STATIC);

		AL.sourcei(source, AL.BUFFER, buffer);

		AL.sourcePlay(source);
		// haxe.Timer.delay(()-> AL.sourcePlay(source), 100);
	}
	*/
}
