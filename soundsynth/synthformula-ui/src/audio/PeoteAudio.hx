package audio;

// import haxe.io.Float32Array;

#if html5
import audio.web.AudioWeb as AudioBackend;
import audio.web.BufferWeb as BufferBackend;
#else
import audio.openAL.AudioOpenAL as AudioBackend;
import audio.openAL.BufferOpenAL as BufferBackend;
#end

// ------------------------------------------------
// ----------- PeoteAudio - Wrapper ---------------
// ------------------------------------------------

@:forward
@:forwardStatics
abstract PeoteAudio(AudioBackend) from AudioBackend to AudioBackend
{
	public inline function new(sampleRate:Int) 
	{
		this = new AudioBackend(sampleRate);
	}
	
	// MORE HERE to wrap around both
	
}


@:forward
@:forwardStatics
abstract AudioBuffer(BufferBackend) from BufferBackend to BufferBackend
{
/*
	public inline function new(peoteAudio:PeoteAudio, duration:Float) 
	{
		// this = new MonoFloat32BufferBackend(Math.round(sampleRate*duration));
		this = new BufferBackend(peoteAudio, duration);
	}
*/
	// MORE HERE to wrap around both
	
}

