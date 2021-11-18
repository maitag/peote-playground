package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.UniformFloat;

class TriVertex implements Element
{
	//@custom public var tip:Float = 0.5;
	//@posX @formula("x - w*tip") public var x:Float;	
	@posX @formula("x - w * mouseX") public var x:Float;
	@posY public var y:Float;
	
	// size
	@sizeX @formula("aPosition.y * w") public var w:Float;
	@sizeY public var h:Float;
	
	static public var buffer:Buffer<TriVertex>;
	static public var program:Program;

	// -----------------------------------------------
	
	static public function init(uniforms:Array<UniformFloat>, display:Display)
	{	
		buffer = new Buffer<TriVertex>(1, 1, true);
		program = new Program(buffer);
		
		program.injectIntoVertexShader(uniforms);

		
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
