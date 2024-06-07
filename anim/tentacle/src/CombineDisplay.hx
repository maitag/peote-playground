package;

import peote.view.*;

class CombineElement implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX @const public var x:Int = 0;
	@posY @const public var y:Int = 0;
	
	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	public function new(w:Int, h:Int) {
		this.w = w;
		this.h = h;
	}
}

@:forward(x, y, width, height)
abstract CombineDisplay(Display) to Display
{
	public function new(x:Int, y:Int, w:Int, h:Int, uvAoAlphaTexture:Texture, lightTexture:Texture)
	{	
		this = new Display(x, y, w, h);
		
		var buffer = new Buffer<CombineElement>(1);			
		var program = new Program(buffer);

		program.blendEnabled = true;

		program.setTexture(uvAoAlphaTexture, "uvAoAlpha", false);
		program.setTexture(lightTexture, "light", false);
		program.setColorFormula( "vec4( vec3(uvAoAlpha/1.5 + light/1.5), uvAoAlpha.a)");
				
		this.addProgram(program);

		buffer.addElement(new CombineElement(w, h));
	}

}
