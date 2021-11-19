package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.UniformFloat;

class Test implements Element
{
	
/*	@custom @formula("x0") public var x0:Float = 200.0;
	//@custom @formula("x1") public var x1:Float = 200.0;
	@custom @formula("x1 * mouseX") public var x1:Float = 200.0;
	
	@custom @formula("y0") public var y0:Float = 200.0;
	@custom @formula("y0 + y1 * mouseY") public var y1:Float = 200.0;
	
	@posX @formula("mix(x0, x1, aPosition.y)") public var x:Float;
	@posY @formula("mix(y1, y0, aPosition.x)") public var y:Float;
	
	// size
	@custom @formula("w0") public var w0:Float = 200.0;
	@custom @formula("w1") public var w1:Float = 200.0;
	
	@custom @formula("h0") public var h0:Float = 100.0;
	@custom @formula("h1") public var h1:Float = 200.0;
	
	@sizeX @formula("mix(w0, w1-x1+x0, aPosition.y)") public var w:Float;
	@sizeY @formula("mix(h1, h0, aPosition.x)") public var h:Float;
*/	
	
/*
	//@posX @formula("x") public var x:Float=100.0;
	@posX @formula("x - (50.0-100.0*mouseX) * aPosition.y") public var x:Float=100.0;
	//@posY @formula("y") public var y:Float=100.0;
	@posY @formula("y - (50.0-100.0*mouseY) * aPosition.x") public var y:Float = 100.0;
	
	//@sizeX @formula("w") public var w:Float=100.0;
	@sizeX @formula("w + 2.0*(50.0-100.0*mouseX) * aPosition.y") public var w:Float=100.0;
	//@sizeY @formula("h") public var h:Float=100.0;
	@sizeY @formula("h + 2.0*(50.0-100.0*mouseY) * aPosition.x") public var h:Float=100.0;
*/	
	
	@posX @formula("x") public var x:Float= 500.0;
	@posY @formula("y") public var y:Float = 100.0;
	
	//@sizeX @formula("w + (50.0) * aPosition.y") public var w:Float = 100.0;
	@sizeX @formula("w") public var w:Float = 100.0;
	@sizeY @formula("h") public var h:Float = 100.0;
	
	@pivotX @formula("px + (50.0-100.0*mouseX) * aPosition.y") public var px:Float = 50.0;
	@pivotY @formula("py + (50.0-100.0*mouseY) * aPosition.x") public var py:Float = 50.0;

	static public var buffer:Buffer<Test>;
	static public var program:Program;

	// -----------------------------------------------
	
	static public function init(uniforms:Array<UniformFloat>, display:Display)
	{	
		buffer = new Buffer<Test>(1, 1, true);
		program = new Program(buffer);
		
		program.injectIntoVertexShader(uniforms);

		
		display.addProgram(program);
	}
	
	
	
	public function new(x:Int = 10, y:Int = 10, w:Int = 200, h:Int = 200) 
	{
		//this.x = x;
		//this.y = y;
		//this.w = w;
		//this.h = h;
		buffer.addElement(this);
	}

}
