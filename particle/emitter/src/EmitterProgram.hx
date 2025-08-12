package;

import peote.view.*;

@:structInit class Params {
	@:optional public var ft:String;

	@:optional public var fx:String;
	@:optional public var fy:String;
	@:optional public var fw:String;
	@:optional public var fh:String;

	@:optional public var fa:String;
	@:optional public var fd:String;
} 

class EmitterProgram extends Program
{
	var buff:Buffer<Particle>;

	public function new(params:Params) {

		buff = new Buffer<Particle>(1024,1024);
		super(buff);

		autoUpdate = false;

		injectIntoVertexShader(true);
		
		// formulas
		if (params.ft != null) setFormula("t", params.ft);
		else setFormula("t", "(uTime-t)/(duration*0.001)");
		
		if (params.fx != null) setFormula("x", params.fx);
		if (params.fy != null) setFormula("y", params.fy);
		if (params.fw != null) setFormula("w", params.fw);
		if (params.fh != null) setFormula("h", params.fh);

		if (params.fa != null) setFormula("a", params.fa);
		if (params.fd != null) setFormula("d", params.fd);

		blendEnabled = true;

		update();
	}
	
	public inline function addNewParticle(ex:Int, ey:Int, sx:Int, sy:Int, color:Color, spawnTime:Float, duration:Int, seed:Int):Particle
	{
		return buff.addElement( new Particle(ex, ey, sx, sy, color, spawnTime, duration, seed) );
	}

	public inline function removeParticles(particles:Array<Particle>)
	{
		for (particle in particles) buff.removeElement( particle );
	}

}
