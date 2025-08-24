package;

import peote.view.*;

class DisplayRings extends Display
{
	var buffer:Buffer<Particle>;

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color = 0x00000000) {

		super(x, y, width, height, color);

		// Fill up the BUFFER:
		buffer = new Buffer<Particle>(90);
		for (i in 0 ... 90) {
			var p = new Particle(i*4, Color.random());
			buffer.addElement(p);
		}

		for (i in 0...41) {
			addTimedFormulaProgram(i*0.092);
		}
	}


	function addTimedFormulaProgram(time:Float) {

		var program = new Program(buffer);

		program.autoUpdate = false;

		program.injectIntoVertexShader(true);
		
		// position in depend of angle and distance (what changes over time)
		time += Math.random()*0.03;
		program.setFormula("x", '${width>>1}.0  + mod(($time+uTime)*80.0, 300.0) * cos(a)');
		program.setFormula("y", '${height>>1}.0 + mod(($time+uTime)*80.0, 300.0) * sin(a)');

		// randomize the angle a bit
		time += Math.random()*0.3;
		program.setFormula("a", 'a+uTime*0.3+$time');

		// program.update();

		program.blendEnabled = true;

		addProgram(program);
	}

}
