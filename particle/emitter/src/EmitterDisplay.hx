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
		for (i in 0...1) {
			var p = new EmitterProgram( formula.get(i) );
			emitterProgram.set(i, p);
			addProgram(p);
		}
		
	}

	public function spawn(type:EmitterType, steps:Int, param:SpawnParam)
	{
		// start spawning over time
		spawnStep(steps, emitterProgram.get(type), param);
	}

	function spawnStep(step:Int, program:EmitterProgram, param:SpawnParam)
	{
		var particles = new Array<Particle>();

		for (i in 0...param.spawn) {
			particles.push(
				program.addNewParticle(
					param.ex, param.ey, // emitter spawnpoint
					param.sx, param.sy, // how far particles go away per duration
					Color.random(),
					peoteView.time, // spawn time
					param.duration, // how long particles exists (per spawn)
					Std.random(0x7fff) // seeds
				) 
			);
		}

		Timer.delay( program.removeParticles.bind(particles), param.duration );


		// ------ next spawn after duration ----------

		// TODO: let the "param" change, e.g. change amount of new spawned etc.
		// var newParam = { spawn:param.spawn++ ...}

		if (--step > 0)
			Timer.delay(
				spawnStep.bind(step, program, param),
				param.delay
			);

	}

}
