package;

import peote.view.*;

class ElementView implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int = 0;
	@posY public var y:Int = 0;
	
	// size in pixel
	@sizeX public var w:Int = 128;
	@sizeY public var h:Int = 128;
	
	// --------------------------------------------------------------------------
	
	public function new(x:Int = 0, y:Int = 0, w:Int = 128, h:Int = 128)
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

}
