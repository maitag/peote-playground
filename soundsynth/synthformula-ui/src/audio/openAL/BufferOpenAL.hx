package audio.openAL;

// ------------------------------------------------
// ------------------- OpenAL ---------------------
// ------------------------------------------------

import haxe.io.Bytes;
import haxe.io.Float32Array;

import lime.media.openal.AL;
import lime.media.openal.ALBuffer;

class BufferOpenAL
{
	public var buffer(default, null):ALBuffer;
	public var duration(default, null):Float;

	public inline function new(duration:Float) {
		this.duration = duration;
		AL.getError();
		buffer = AL.createBuffer();
		if (AL.getError() != AL.NO_ERROR) trace("AL ERROR: buffer create");
	}

	public function setData(data:Float32Array, sampleRate:Int = 0) {
		/*
		// converts Float32Array data into Bytes for FORMAT_MONO16
		var bufferBytes = Bytes.alloc(data.view.buffer.length << 1);
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
		*/

		// hashlink gives error here:
		// trace(AL.getErrorString());
		AL.getError();
		AL.bufferData(buffer, AudioOpenAL.AL_FORMAT_MONO_FLOAT32,
			lime.utils.Float32Array.fromBytes(data.view.buffer),
			data.view.buffer.length, (sampleRate > 0) ? sampleRate: AudioOpenAL.sampleRate);
		
		if (AL.getError() != AL.NO_ERROR) trace("AL ERROR: buffer set data");
		// trace(buffer);
	}
	
}
