package;

import peote.view.Element;
import peote.view.Color;

class Number implements Element
{
	@custom public var precision:Int = 1;

	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;
	
	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	// color (RGBA)
	@color public var c:Color = 0xff0000ff;

	// the tile->NUMBER
	@texTile public var n:Int = 48;

	
	public function new(precision:Int, _x:Int, _y:Int, _w:Int, _h:Int, _c:Color) {
		this.precision = precision;
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		c = _c; //anyway ;) -> LAURA \o/
	}
}
