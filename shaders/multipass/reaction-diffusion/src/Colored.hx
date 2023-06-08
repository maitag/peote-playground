package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Texture;
import peote.view.utils.Util;

class Colored implements Element
{
	// position in pixel (relative to upper left corner of Display)
	//@posX public var x:Int;
	//@posY public var y:Int;
	
	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	// --------------------------------------------------------------------------
	
	static public var buffer:Buffer<Colored>;
	static public var program:Program;	

	static public function init(display:Display, texture:Texture, colors:Array<Color>, steps:Array<Float>)
	{	
		buffer = new Buffer<Colored>(1, 1, true);
		program = new Program(buffer);
		
		// create a texture-layer named "base"
		program.setTexture(texture, "base", true);

		var formula = Util.color2vec4(colors[0]);
		
		for (i in 1...colors.length) {
			var col = Util.color2vec4(colors[i]);
			var from = Util.toFloatString(steps[i-1]);
			var to = Util.toFloatString(steps[i]);
			formula = 'mix($formula, $col, smoothstep($from, $to, 1.0 - base.r ))';
		}
		program.setColorFormula( formula );
		
		program.blendEnabled = false;
		display.addProgram(program);
	}
	
	
	public function new(w:Int, h:Int)
	{
		this.w = w;
		this.h = h;
		buffer.addElement(this);
	}
	
	public function update() buffer.updateElement(this);

}
