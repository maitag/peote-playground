package;

import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;


class ColorbandDisplay extends Display 
{

	var program:Program;
	var buffer:Buffer<HGradient>;
	
	public function new(x:Int, y:Int, width:Int, height:Int) 
	{
		super(x, y, width, height);
		
		buffer = new Buffer<HGradient>(8, 8, true);
		
		program = new Program(buffer);
		program.injectIntoFragmentShader(HGradient.fShader);
		
		this.addProgram(program);
	}
	
	public function create(colorband:Colorband )
	{
		// for testing the shadercode only:
		buffer.addElement(new HGradient());

		
		// TODO:
		
		//for (i in 0...colorband.length) {
			//buffer.addElement( new HGradient() );
			//
		//}
	}
	
	
}