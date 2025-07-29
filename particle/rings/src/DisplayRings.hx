package;

import peote.view.*;

class DisplayRings extends Display
{
	var buffer:Buffer<Particle>;

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color = 0x00000000) {

		super(x, y, width, height, color);

		// Fill up the BUFFER:
		buffer = new Buffer<Particle>(1024,1024);
		for (i in 0 ... 360) {
			var p = new Particle(i, 200);
			buffer.addElement(p);
		}

		// here into a LOOP at the END ;)
		addTimedFormulaProgram(1.0);
	}


	function addTimedFormulaProgram(time:Float) {

		var program = new Program(buffer);

		program.injectIntoVertexShader(true);

		// what is formula ... ?
		// in depend of angle "a"
		// and distance "d" ?
		program.setFormula("x", '${width>>1} + d * cos(a)'); // <-- uTime later
		program.setFormula("y", '${height>>1} + d * sin(a)'); // <-- uTime later

		// hey filt3rek, do you have some -> easyout @formula 4mme ;)


		addProgram(program);
	}

}
