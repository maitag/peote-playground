package;

import peote.view.*;

class Triangle implements Element
{
	@posX public var x:Float;
	@posY public var y:Float;
	
	// size in pixel
	@sizeX public var w:Float;
	@sizeY public var h:Float;
	
	//@custom @varying public var tip:Float = 0.2;
	
	// TODO: triangle shape depending on some extra @custom vars	

	static public var buffer:Buffer<Triangle>;
	static public var program:Program;

	// -----------------------------------------------
	
	static public function init(uniforms:Array<UniformFloat>, display:Display)
	{	
		buffer = new Buffer<Triangle>(1, 1, true);
		program = new Program(buffer);
		
		program.injectIntoFragmentShader(
		"
			// float triangle( vec2 texCoord, float t )
			float triangle( vec2 texCoord )
			{
				
				// float t = 0.5;
				float t = mouseX;
				
				float x = vTexCoord.x;
				float y = 1.0 - vTexCoord.y;
				
				float c;
				
				if (  x > y*t && 1.0 - x > y*(1.0-t)) {
					c = 1.0;
				}
				else {
					c = 0.0;
				}
				return c;
			}			
		",
		uniforms
		);

		//program.setColorFormula( 'triangle(vTexCoord, tip)' );
		program.setColorFormula( 'vec4(1.0)*triangle(vTexCoord)' );
		
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
