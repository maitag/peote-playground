package;

import haxe.ds.Vector;
import peote.view.*;

enum abstract PointEffect(Int) from Int to Int {
	var SUNRAYS;
	var SPIRAL;
}

@:forward abstract PointEffectFormula( Map<PointEffect, PointProgram.PointFormulas> ) {
	public function new() {
		this = [
			SUNRAYS => {
				fx: "ex + mod((uTime)*300.0, 150.0) * cos(0.0)",
			 	fy: "ey + mod((uTime)*300.0, 150.0) * sin(0.0)"
			}
			// SPIRAL  => {fx:"", fy:""}
		];
	}
}

class EmitterDisplay extends Display
{
	var pointProgram = new Vector<PointProgram>(5);
	// var linePrograms = new Vector<LineProgram>(5);
	// ...

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color = 0x00000000) {

		super(x, y, width, height, color);

		// create programs for different emitter-type (e.g. point, line, etc.) and effects (by formulas)
		
		// create all "point"-emitter programs with its formulas 
		var pointEffectFormula = new PointEffectFormula();
		for (i in 0...1) {
			var p = new PointProgram( pointEffectFormula.get(i) );
			pointProgram.set(i, p);
			addProgram(p);
		}
		
	}

	public function point(effect:PointEffect, emitterPointX:Int, emitterPointY:Int, color:Color, seed:Int, timeDiff:Int) {

		pointProgram.get(effect).spawn(emitterPointX, emitterPointY, color, seed, timeDiff);

	}

}
