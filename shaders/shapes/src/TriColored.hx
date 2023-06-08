package;

import peote.view.Color;
import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.UniformFloat;

class TriColored implements Element
{
	@color public var ca:Color = 0xff0000ff;
	@color public var cb:Color = 0x00ff00ff;
	@color public var cc:Color = 0x0000ffff;
	
	@posX public var x:Float;
	@posY public var y:Float;
	
	// size in pixel
	@sizeX public var w:Float;
	@sizeY public var h:Float;
	

	// ---------------------------
	
	static public var buffer:Buffer<TriColored>;
	static public var program:Program;

	// -----------------------------------------------
	
	static public function init(uniforms:Array<UniformFloat>, display:Display)
	{	
		buffer = new Buffer<TriColored>(1, 1, true);
		program = new Program(buffer);
		
		program.injectIntoFragmentShader(
		"
			// vec4 triangle( vec2 texCoord, float t )
			vec4 triangle( vec2 texCoord )
			{
				
				//float t = 0.5;
				float t = mouseX; // using uniform here for better testing
				
				float x = vTexCoord.x;
				float y = 1.0 - vTexCoord.y;
				
				vec4 c = vec4(0.0, 0.0, 0.0, 0.0);;
				
				// look here for barycentric interpolation https://codeplea.com/triangular-interpolation				
				//float w0 = y;
				//float w1 = -1.0*(x-1.0) + (t-1.0)*y;
				//float w2 = 1.0 - w0 - w1;
				//
				//if (w0 >= 0.0 && w1 >= 0.0 && w2 >= 0.0) {
					//c = vColor0*w0 + vColor1*w1 + vColor2*w2;
				//}
				
				// optimized:
				float w1 = 1.0 - x + (t-1.0)*y;
				float w2 = 1.0 - y - w1;
				
				if (w1 >= 0.0 && w2 >= 0.0) {
					c = vColor0*y + vColor1*w1 + vColor2*w2;
				}
								
				return c;
			}			
		",
		uniforms
		);

		//program.setColorFormula( 'triangle(vTexCoord, tip)' );
		program.setColorFormula( 'triangle(vTexCoord)' );
		
		program.blendEnabled = true;
		program.discardAtAlpha(0.0);
		
		display.addProgram(program);
	}
	
	
	
	public function new(x:Int = 0, y:Int = 0, w:Int = 100, h:Int = 100) 
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		buffer.addElement(this);
	}

}
