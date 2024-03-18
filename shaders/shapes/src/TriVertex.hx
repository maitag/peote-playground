package;

import peote.view.*;

class TriVertex implements Element
{
	@color public var ca:Color = 0xff0000ff;
	@color public var cb:Color = 0x00ff00ff;
	@color public var cc:Color = 0x0000ffff;
	
	//@custom public var tip:Float = 0.5; // mouseX-uniform can be replaced by custom attribute later
	
	//@posX @formula("x + (aSize.x - w)*((mouseX-0.5)*2.0+mouseX)") public var x:Float;
	//@posX @formula("x + (aSize.x - w)*((2.0*mouseX-1.0)*2.0+mouseX)") public var x:Float;
	@posX @formula("x + (aSize.x - w)*((2.0*mouseX-1.0)* 1.0 +mouseX)") public var x:Float;
	
	//@posX @formula("x + (aSize.x - w)*(mouseX-1.0/3.0)*3.0") public var x:Float;
	//@posX @formula("x + (aSize.x - w)*(mouseX-1.0/2.7)*4.0") public var x:Float;
	
	@posY public var y:Float;
	
	// size
	@sizeX @formula("aPosition.y * w") public var w:Float;
	@sizeY public var h:Float;
	
	//@rotation public var r:Float = 45.0;
	
	static public var buffer:Buffer<TriVertex>;
	static public var program:Program;

	// -----------------------------------------------
	
	static public function init(uniforms:Array<UniformFloat>, display:Display)
	{	
		buffer = new Buffer<TriVertex>(1, 1, true);
		program = new Program(buffer);
		
		program.injectIntoVertexShader(uniforms);
		
		program.injectIntoFragmentShader(
		"
			vec4 triangleColor( vec2 texCoord )
			{
				//float y = 1.0 - vTexCoord.y;
				//float w1 = 1.0 - vTexCoord.x;
				//float w2 = 1.0 - y - w1;
				
				//return vColor0*y + vColor1*w1 + vColor2*w2;
				
				return vColor0*(1.0 - vTexCoord.y) + vColor1*(1.0 - vTexCoord.x) + vColor2*(vTexCoord.y - 1.0 + vTexCoord.x);
			}			
		");

		program.setColorFormula( 'triangleColor(vTexCoord)' );

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
