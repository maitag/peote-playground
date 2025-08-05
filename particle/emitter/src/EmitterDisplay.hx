package;

import haxe.ds.Vector;
import peote.view.*;


class EmitterDisplay extends Display
{
	var emitterProgram = new Vector<EmitterProgram>(5);

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color = 0x00000000) {

		super(x, y, width, height, color);

		// create all emitter programs with its formulas 
		var formula = new EmitterType.Formula();
		for (i in 0...1) {
			var p = new EmitterProgram( formula.get(i) );
			emitterProgram.set(i, p);
			addProgram(p);
		}
		
	}

	public function spawn(type:EmitterType, ex:Int, ey:Int, size:Int, color:Color, param:SpawnParam) {

		emitterProgram.get(type).spawn(ex, ey, color, 5, 1);

	}

}
