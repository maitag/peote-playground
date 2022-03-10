package;

import peote.view.Element;
import peote.view.Color;

class ElemPen implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	// size in pixel
	@sizeX public var w:Int=10;
	@sizeY public var h:Int=10;
	
	// pivot point allways into the middle
	@pivotX @const @formula("floor(w/2.0)") public var px:Int;
	@pivotY @const @formula("floor(h/2.0)") public var py:Int;
	
	// color (RGBA)
	@color public var c:Color = 0xff0000ff;
	
	// z-index
	@zIndex public var z:Int = 0;	// take care, if this is enabled and render into texture
	
	public function new(x:Int=0, y:Int=0) {
		this.x = x;
		this.y = y;
	}
}
