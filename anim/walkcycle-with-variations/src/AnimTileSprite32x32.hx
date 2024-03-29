package;

import peote.view.Color;
import peote.view.Element;

class AnimTileSprite32x32 implements Element
{	
	// position
	@posX @anim("Pos") public var x:Int=0;
	@posY public var y:Int=0;
	
	// color
	@color @anim("Col") public var c:Color = 0xffffffFF;

	// size
	@sizeX @const @formula("(xStart > xEnd) ? 32 : -32") var width:Int=32;
	@sizeY @const var height:Int=32;
	
	// texture tile
	@texTile @anim("Tile", "repeat")
	public var tile:Int = 0;
	
	var OPTIONS = { blend:true };
}
