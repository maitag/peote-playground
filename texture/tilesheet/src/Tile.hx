package;

import peote.view.Element;
import peote.view.Color;

class Tile implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int=0;
	@posY public var y:Int=0;

	// to fix the tile y position for the "ditted line" fix
	// @posY @formula("y+1.0") public var y:Int=0;
	
	// size in pixel
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	// rotation around pivot point
	@rotation public var r:Float;
	
	// pivot x (rotation offset)
	@pivotX public var px:Int = 0;

	// pivot y (rotation offset)
	@pivotY public var py:Int = 0;
	
	// color (RGBA)
	// @color public var c:Color = 0xffffffff;
	
	// z-index
	// @zIndex public var z:Int = 0;


	// TEXTURES:
	@texTile public var tile:Int = 0;

	// this is the "dotted line" fix, what moves the texturetile one pixel downwards,
	// to not have upper tiles border pixels into smooth textureinterpolation
	// it the tile is rotated
	@texPosY @const var texPosY:Int = -1;
	
	public function new() {}
}
