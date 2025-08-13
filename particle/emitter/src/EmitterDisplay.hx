package;

import haxe.Timer;
import haxe.ds.Vector;
import haxe.ds.IntMap;
import peote.view.*;


class EmitterDisplay extends Display
{
	var emitterProgram = new Vector<EmitterProgram>(5);

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color = 0x00000000)
	{
		super(x, y, width, height, color);

		// create all emitter programs with its formulas 
		var formula = new EmitterType.Formula();
		for (i in 0...formula.length) {
			var p = new EmitterProgram( formula.get(i) );
			emitterProgram.set(i, p);
			addProgram(p);
		}
		
	}

	public function spawn(type:EmitterType, param:SpawnParam)
	{
		// start spawning over time
		spawnStep(0, emitterProgram.get(type), param);
	}

	function spawnStep(step:Int, program:EmitterProgram, param:SpawnParam)
	{
		var particles = new Array<Particle>();

		var spawn:Int = (param.spawnFunc == null) ? param.spawn : param.spawnFunc(param.spawn, step);
		var duration:Int = (param.durationFunc == null) ? param.duration : param.durationFunc(param.duration, step);

		spawn = minMax(spawn, 1, 4096);
		duration = minMax(duration, 10, 10000);

		for (i in 0...spawn) {
			particles.push(
				program.addNewParticle(
					param.ex, param.ey, // emitter spawnpoint
					param.sx, param.sy, // how far particles go away per duration
					Color.random(),
					// Color.RED,
					peoteView.time, // spawn time
					duration, // how long particles exists (per spawn)
					Std.random(0x8000) // seed
				) 
			);
		}

		Timer.delay( program.removeParticles.bind(particles), duration );


		// ------ next spawn after duration ----------

		if (++step < param.steps)
			Timer.delay(
				spawnStep.bind(step, program, param),
				minMax((param.delayFunc == null) ? param.delay : param.delayFunc(param.delay, step), 10, 100000)
			);

	}

	inline function minMax(value:Int, min:Int, max:Int) {
		if (value < min) value = min;
		else if (value > max) value = max;
		return value;
	}
}
