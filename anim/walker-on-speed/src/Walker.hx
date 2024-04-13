package;

import peote.view.Element;

class Walker implements Element
{
	// only x position is ANIMATED here 
	@posX @anim("X", "repeat")
	public var x:Int=0;

	@posY public var y:Int=0;
	
	// if the size is negative the till will be "mirrored"!
	@sizeX public var size:Int=-128;

	// ---- calculated by formula inside of glsl ----
	
	// height allways same as width (because it is also `quad` inside of texture-data!)
	@sizeY @const @formula("abs(size)") // but allways keep it non-mirrored here!
	var height:Int;

	// pivot point X need to change if size is negative (tile is x-mirrored)
	@pivotX	@const @formula("((size < 0.0) ? size : 0.0)") 
	var px:Int;

	// texture tile number
	@texTile @const @formula("floor(mod(x * 0.13, 23.0))")
	var tile:Int;
	
	var OPTIONS = { blend:true };
}
