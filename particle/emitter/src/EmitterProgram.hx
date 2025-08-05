package;

import peote.view.*;

@:structInit class Params {
	public var fx:String;
	public var fy:String;
	@:optional public var fa:String;
} 

class EmitterProgram extends Program
{
	var buff:Buffer<Particle>;

	public function new(params:Params) {

		buff = new Buffer<Particle>(1024,1024);
		super(buff);

		injectIntoVertexShader(true);
		
		// position formulas
		setFormula("x", params.fx);
		setFormula("y", params.fy);

		blendEnabled = true;

	}

	public function spawn(ex:Int, ey:Int, color:Color, seed:Int, timeDiff:Int) {
		buff.addElement( new Particle(ex, ey, color, seed, timeDiff) );
	}

}
