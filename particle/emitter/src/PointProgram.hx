package;

import peote.view.*;

@:structInit class PointFormulas {
	public var fx:String;
	public var fy:String;
} 

class PointProgram extends Program
{
	var buff:Buffer<PointParticle>;

	public function new(pointFormulas:PointFormulas) {

		buff = new Buffer<PointParticle>(1024,1024);
		super(buff);

		injectIntoVertexShader(true);
		
		// position formulas
		setFormula("x", pointFormulas.fx);
		setFormula("y", pointFormulas.fy);

		blendEnabled = true;

	}

	public function spawn(ex:Int, ey:Int, color:Color, seed:Int, timeDiff:Int) {
		buff.addElement( new PointParticle(ex, ey, color, seed, timeDiff) );
	}

}
