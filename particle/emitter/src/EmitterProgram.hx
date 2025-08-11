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
	
	public inline function addNewParticle(ex:Int, ey:Int, color:Color, seed:Int, timeDiff:Int):Particle
	{
		return buff.addElement( new Particle(ex, ey, color, seed, timeDiff) );
	}

	public inline function removeParticles(particles:Array<Particle>)
	{
		for (particle in particles) buff.removeElement( particle );
	}

}
