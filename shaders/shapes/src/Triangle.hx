package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;

class Triangle implements Element
{
	@posX public var x:Int;
	@posY public var y:Int;
	
	// size in pixel
	@sizeX @varying public var w:Int;
	@sizeY @varying public var h:Int;
		

	static public var buffer:Buffer<Triangle>;
	static public var program:Program;

	// -----------------------------------------------
	
	static public function init(display:Display)
	{	
		buffer = new Buffer<Triangle>(1, 1, true);
		program = new Program(buffer);
		
		program.injectIntoFragmentShader(
		"
			vec4 triangle( vec2 texCoord, vec2 size )
			{
				// TODO: triangle shape depending on some extra @custom vars
				return vec4(0.0, 0.0, 1.0, 1.0);
			}			
		");
		
		program.setColorFormula( 'triangle(vTexCoord, vSize)' );
		
		program.alphaEnabled = true;
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
