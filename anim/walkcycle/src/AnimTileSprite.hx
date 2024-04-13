package;

import peote.view.Element;

class AnimTileSprite implements Element
{
	// position
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	// size
	@sizeX var width:Int=128;
	@sizeY var height:Int=128;


	// ---- animated by shader ----
	
	// texture tile number
	@texTile @anim("Tile", "repeat")
	public var tile:Int = 0;
	
	var OPTIONS = { blend:true };
}
