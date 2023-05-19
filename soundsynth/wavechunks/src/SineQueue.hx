package;

import lime.app.Application;
import lime.media.openal.ALSource;
import lime.media.openal.AL;
import lime.utils.Int16Array;
import haxe.io.Bytes;

class SineQueue extends Application {
	/**

		To continuously stream audio from a source without interruption, buffer queuing is required. To
		use buffer queuing, the buffers and sources are generated in the normal way, but alSourcei is not
		used to attach the buffers to the source. Instead, the functions alSourceQueueBuffers and 
		alSourceUnqueueBuffers are used.

		The program can attach a buffer or a set of buffers to a source using alSourceQueueBuffers,
		and then call alSourcePlay on that source.

		While the source is playing, alSourceUnqueueBuffers can be called to remove buffers which have already
		played. Those buffers can then be filled with new data or discarded. New or refilled buffers can
		then be attached to the playing source using alSourceQueueBuffers.

	**/
	var source:ALSource;

	var block:Bytes;
	var block_count:Int;
	var block_sample_count:Int;
	var block_byte_count:Int;
	var sample_rate:Int;


	override function onWindowCreate() {
		sample_rate = 48000;
		//sample_rate = 41100;
		block_count = 2;
		block_sample_count = Math.ceil(sample_rate / 16);
		block_byte_count = block_sample_count * 2;
		block = Bytes.alloc(block_byte_count);
		block.fill(0, block_byte_count, 1);

		var buffers = AL.genBuffers(block_count);

		for (i in 0...block_count) {
			fill_samples(block_sample_count, block);
			AL.bufferData(buffers[i], AL.FORMAT_MONO16, Int16Array.fromBytes(block), block_byte_count, sample_rate);
		}

		// source will play the buffered audio
		source = AL.createSource();

		// queue the buffers
		AL.sourceQueueBuffers(source, block_count, buffers);

		// start playing
		AL.sourcePlay(source);
	}

	
	
	var PI2 = 2.0 * Math.PI;
	var position:Int = 0;
	var n:Int = 0;
	var sample:Int = 0;
	var freq:Float = 220.0;
	var last_freq:Float = 220.0;
	var position_offset:Float = 0.0;
	
	// for how it is calculating the "offset": https://www.desmos.com/calculator/isktu8looo?lang=de
	
	inline function sine(position:Float, freqPIsampleRateFactor:Float, offset:Float, ):Float {
		return Math.sin( freqPIsampleRateFactor * position  + offset  );		
	}

	function fill_samples(sample_count:Int, block:Bytes) {
		position_offset += (last_freq - freq) * (PI2 * position / sample_rate);
		last_freq = freq;
		n = 0;
		var freqPIsampleRateFactor:Float = freq * PI2 / sample_rate;
		for(i in 0...sample_count){
			sample = Std.int(32767.0 * sine(position++, freqPIsampleRateFactor, position_offset));
			block.set(n++, sample);
			block.set(n++, sample >> 8);
		}
	}

	override function update(deltaTime:Int) {
		var num_buffers_finished:Int = AL.getSourcei(source, AL.BUFFERS_PROCESSED);
		if (num_buffers_finished > 0) {
			// iterate the buffers that need to be refilled
			var finished_buffers = AL.sourceUnqueueBuffers(source, num_buffers_finished);
			for (buffer in finished_buffers) {
				fill_samples(block_sample_count, block);
				AL.bufferData(buffer, AL.FORMAT_MONO16, Int16Array.fromBytes(block), block_byte_count, sample_rate);
				AL.sourceQueueBuffer(source, buffer);
			}
		}

		// source will stop if buffers have finished so test and keeping it playing here
		if (AL.getSourcei(source, AL.SOURCE_STATE) != AL.PLAYING) {
			AL.sourcePlay(source);
		}
	}

	var max = 220.00;
	var min = 440.00;
	override function onMouseMove(x:Float, y:Float) {
		var range = max-min;
		freq = ((1.0  - (y / window.height)) * range) + min;
	}
}
