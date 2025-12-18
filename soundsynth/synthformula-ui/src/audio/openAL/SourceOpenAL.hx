package audio.openAL;

// ------------------------------------------------
// ------------------- OpenAL ---------------------
// ------------------------------------------------

import lime.media.openal.*;

class SourceOpenAL
{
	#if hl
	// little hack to prevent hashlinks garbage collector from deleting the source al-pointer too early
	static var _sources = new haxe.ds.Vector<ALSource>(3);
	static var _sourcesIndex:Int = 0;
	public var source(default, set):ALSource;
	inline function set_source(s:ALSource):ALSource {
		_sources.set(_sourcesIndex++, s);
		if (_sourcesIndex >= _sources.length) _sourcesIndex = 0;
		return source = s;
	}
	#else
	public var source(default, null):ALSource;
	#end

	public function new(audioBuffer:BufferOpenAL)
	{
		AL.getError();
		source = AL.createSource();
		if (AL.getError() != AL.NO_ERROR) trace("AL ERROR: source create");
		
		// source = AL.genSources(1)[0];

		AL.getError();
		AL.sourcef  (source, AL.PITCH, 1.0);
		AL.sourcef  (source, AL.GAIN, 1.0);
		AL.source3f (source, AL.POSITION, 0.0, 0.0, 0.0); // for first value: -1.0 -> left, 1.0 -> right
		AL.source3f (source, AL.VELOCITY, 0.0, 0.0, 0.0);
		// AL.sourcei(source, AL.SOURCE_TYPE, AL.STATIC);
		// AL.sourcei(source, AL.SOURCE_TYPE, AL.STREAMING);
		if (AL.getError() != AL.NO_ERROR) trace("AL ERROR: source set properties");
		
		AL.getError();
		AL.sourcei(source, AL.BUFFER, audioBuffer.buffer);
		if (AL.getError() != AL.NO_ERROR) trace("AL ERROR: source bind to buffer");

		// trace(source);
	}

	public function play()
	{
		AL.getError();
		AL.sourcePlay(source);	
		if (AL.getError() != AL.NO_ERROR) trace("AL ERROR: source play");
	}
	
	// TODO: clean up source after playing
	// if (source!=null) AL.deleteSource(source);
}
