package;

import haxe.Timer;
import haxe.ds.Vector;
import haxe.ds.IntMap;
import peote.view.*;


class EmitterDisplay extends Display
{
	var emitterProgram:Vector<EmitterProgram>;
	
	public var maxTypes(get, never):Int;
	inline function get_maxTypes():Int return emitterProgram.length - 1;


	public function new(x:Int, y:Int, width:Int, height:Int, color:Color = 0x00000000)
	{
		super(x, y, width, height, color);

		// create all emitter programs with its formulas 
		var formula = new EmitterType.Formula();

		emitterProgram = new Vector<EmitterProgram>(formula.length);

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
		spawn = minMax(spawn, 1, 4096);
		
		var duration:Int = (param.durationFunc == null) ? param.duration : param.durationFunc(param.duration, step);
		duration = minMax(duration, 10, 10000);


		for (i in 0...spawn) {
			particles.push(
				program.addNewParticle(
					// emitter spawnpoint
					(param.exFunc == null) ? param.ex : param.exFunc(param.ex, step, i),
					(param.eyFunc == null) ? param.ey : param.eyFunc(param.ey, step, i),
					
					// size of particle
					minMax( (param.sizeFunc == null) ? param.size : param.sizeFunc(param.size, step, i), 1, 32766), 
					
					// how far particles go away per duration
					(param.sxFunc == null) ? param.sx : param.sxFunc(param.sx, step, i),
					(param.syFunc == null) ? param.sy : param.syFunc(param.sy, step, i),

					// start and end colors
					(param.colorStartFunc == null) ? param.colorStart : param.colorStartFunc(param.colorStart, step, i),
					(param.colorEndFunc == null) ? param.colorEnd : param.colorEndFunc(param.colorEnd, step, i),
					
					// spawn time
					peoteView.time,
					
					// how long particles exists in milliseconds (per spawn)
					duration,
					
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
