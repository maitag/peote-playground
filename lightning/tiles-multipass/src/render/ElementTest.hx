package render;

import peote.view.*;

class ElementTest implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int = 0;
	@posY public var y:Int = 0;
		
	// size in pixel
	@sizeX public var w:Int = 128;
	@sizeY public var h:Int = 128;
	
	// tile number
	@texTile("uvAoAlpha", "normalDepth") var tile:Int = 1;

	// var OPTIONS = { texRepeatX:true, texRepeatY:true };

	// --------------------------------------------------------------------------
	
	public function new(tile:Int = 0, x:Int = 0, y:Int = 0, w:Int = 128, h:Int = 128)
	{
		this.tile = tile;
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

}
