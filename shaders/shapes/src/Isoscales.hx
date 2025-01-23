package;

import peote.view.*;

class Isoscales implements Element
{
	@posX @formula("x") public var x:Float=400.0;
	// @posX @formula("x - (50.0-100.0*mouseX) * aPosition.y") public var x:Float=100.0;

	@posY @formula("y") public var y:Float=300.0;
	// @posY @formula("y - (-100.0*mouseY) * aPosition.x") public var y:Float = 100.0;
	
	@sizeX @formula("w") public var w:Float=300.0;
	// @sizeX @formula("w + 2.0*(50.0-100.0*mouseX) * aPosition.y") public var w:Float=100.0;

	// @sizeY @formula("h") public var h:Float=100.0;
	@sizeY @formula("h - mouseY*h * (1.0-aPosition.x)") public var h:Float=300.0;
	
	@pivotX public var px:Float = 0.0;
	// @pivotX @formula("px + (50.0-100.0*mouseX) * aPosition.y") public var px:Float = 50.0;
	// @pivotY public var py:Float = 0.0;
	// @pivotY @formula("py + 2.0*(-100.0*mouseX) * aPosition.x  * h/w") public var py:Float = 0.0;
	@pivotY @const @formula("h/2.0") public var py:Float;
	
	@rotation @formula("r + rotation") public var r:Float = 0.0;

	static public var buffer:Buffer<Isoscales>;
	static public var program:Program;

	// -----------------------------------------------
	
	static public function init(uniforms:Array<UniformFloat>, display:Display)
	{	
		buffer = new Buffer<Isoscales>(1, 1, true);
		program = new Program(buffer);
		
		program.injectIntoVertexShader(uniforms);

		
		display.addProgram(program);
	}
	
	
	
	public function new(x:Int = 200, y:Int = 200, w:Int = 200, h:Int = 200) 
	{
		/*this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;*/
		buffer.addElement(this);
	}

}
