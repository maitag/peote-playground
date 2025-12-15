package audio.web;

// ------------------------------------------------
// ------------------- WebAudio -------------------
// ------------------------------------------------

import haxe.io.Float32Array;
import js.html.audio.AudioBuffer;

class BufferWeb
{
	public var buffer(default, null):AudioBuffer;
	public var duration(default, null):Float;

	public function new(duration:Float)
	{
		this.duration = duration;

		// TODO: not conform with openAL buffer-backend
		// buffer = AudioWeb.context.createBuffer(1, data.view.buffer.length, AudioWeb.sampleRate);
	}

	public function setData(data:Float32Array, sampleRate:Int = 0)
	{
		buffer = AudioWeb.context.createBuffer(1, data.view.buffer.length, AudioWeb.sampleRate);
		buffer.copyToChannel( cast data, 0, 0);
	}

}