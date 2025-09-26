package render;

import peote.view.Element;
import peote.view.Color;

class ElementLight implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@varying @posX public var x:Int = 0;
	@varying @posY public var y:Int = 0;
	
	@varying @custom public var depth:Float = 0.0;
	
	// size in pixel
	@varying @sizeX public var size:Int = 100;
	@sizeY @const @formula("size") var h:Int;
		
	//color
	@color public var color:Color;

	public function new(x:Int = 0, y:Int = 0, size:Int = 100, color:Int = Color.WHITE) {
		this.x = x;
		this.y = y;
		this.size = size;
		this.color = color;
	}

}
