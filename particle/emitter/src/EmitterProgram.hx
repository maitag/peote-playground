package;

import peote.view.*;

@:structInit class Params {
	public var ft = "(uTime-t)/(duration*0.001)";

	public var fx = "ex + t*sx";
	public var fy = "ey + t*sy";
	
	public var fw = "size";
	public var fh = "size";

	public var fc = "mix(cs, ce, t)";
	
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

		// ok -> lets _inject ->
		injectIntoVertexShader("
			#define PI 3.1415926535897932384626433832795

			float random(float seed, float min, float max) {
				return mix( min, max, seed / 32767.0);
			}
		",
		true);
		
		setFormula("t", params.ft);

		setFormula("x", params.fx);
		setFormula("y", params.fy);
		setFormula("w", params.fw);
		setFormula("h", params.fh);
		
		if (params.fa != null) setFormula("a", params.fa);
		if (params.fd != null) setFormula("d", params.fd);

		setColorFormula(params.fc);
		blendEnabled = true;

		update();
	}
	
	public inline function addNewParticle(ex:Int, ey:Int, size:Int, sx:Int, sy:Int, colorStart:Color, colorEnd:Color, spawnTime:Float, duration:Int, seed:Int):Particle
	{
		return buff.addElement( new Particle(ex, ey, size, sx, sy, colorStart, colorEnd, spawnTime, duration, seed) );
	}

	public inline function removeParticles(particles:Array<Particle>)
	{
		for (particle in particles) buff.removeElement( particle );
		particles = null;
	}

}
