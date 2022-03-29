package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Texture;
import peote.view.Color;

class Canvas implements Element
{
	@sizeX public var w:Float;	
	@sizeY public var h:Float;
	
	//var OPTIONS = { alpha:false };

	static var buffer:Buffer<Canvas>;
	static var program:Program;
	
	public static var texture:Texture;
	
	public static function init(display:Display)
	{
		buffer = new Buffer<Canvas>(1, 1);
		program = new Program(buffer);
		
		texture = new Texture(display.width, display.height);
		texture.clearOnRenderInto = false; // to not clear the texture before rendering into

		program.setTexture(texture, "renderFrom");
		program.discardAtAlpha(null);
		
		display.addProgram(program);	
	}

	
	public function new(w:Float=800, h:Float=600 )
	{
		this.w = w;
		this.h = h;
		buffer.addElement(this);
	}	
	
}
