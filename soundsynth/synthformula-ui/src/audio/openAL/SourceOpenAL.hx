package audio.openAL;

// ------------------------------------------------
// ------------------- OpenAL ---------------------
// ------------------------------------------------

import lime.media.openal.*;

class SourceOpenAL
{
	public var source(default, null):ALSource;

	public function new(audioBuffer:BufferOpenAL)
	{
		source = AL.createSource();
		
		AL.sourcef  (source, AL.PITCH, 1.0);
		AL.sourcef  (source, AL.GAIN, 1.0);
		AL.source3f (source, AL.POSITION, 0.0, 0.0, 0.0); // for first value: -1.0 -> left, 1.0 -> right
		AL.source3f (source, AL.VELOCITY, 0.0, 0.0, 0.0);
		
		// AL.sourcei(source, AL.SOURCE_TYPE, AL.STATIC);
		
		AL.sourcei(source, AL.BUFFER, audioBuffer.buffer);
	}

	public function play()
	{
		AL.sourcePlay(source);		
	}
	
}
