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
	
	// TODO: adding another param for scale up to display-size
	public function create(colorband:Colorband, y:Int, height:Int, defaultSize:Int = 32, defaultInterpolate:Interpolate = null )
	{
		if (defaultInterpolate == null) defaultInterpolate = Interpolate.SMOOTH;
		
		var x:Int = 0;
		
		for (i in 0...colorband.length) {
			
			var c = colorband[i];
			
			if (i < colorband.length - 1) {
				
				var size:Int = (c.size == null) ? defaultSize : c.size;
				trace(size);
				var interpolate:Interpolate = (c.interpolate == null) ? defaultInterpolate : c.interpolate;
				var interpolateStart:Float = (interpolate.start == null) ? defaultInterpolate.start : interpolate.start;
				var interpolateEnd:Float = (interpolate.start == null) ? defaultInterpolate.start : interpolate.end;
				buffer.addElement( new HGradient(x, y, size, height, c.color, colorband[i+1].color, interpolateStart, interpolateEnd) );
				x += size;
			}
			else { // last into array
				
			}
			
		}
	}
	
	
}