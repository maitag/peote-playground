package;

import peote.view.Element;

class Walker implements Element
{
	// only x position is ANIMATED here 
	@posX @anim("X", "repeat")
	public var x:Int;

	@posY public var y:Int;
	
	// custom "size" attribute
	@custom public var size:Int;


	// ---- calculated by formula inside of glsl ----

	@sizeX @const @formula("size * ((xStart < xEnd) ? -1.0 : 1.0)")
	var w:Int;
	
	// height allways same as width (because it is also `quad` inside of texture-data!)
	@sizeY @const @formula("size") // but allways keep it non-mirrored here!
	var h:Int;

	// pivot point X need to change if size is negative (tile is x-mirrored)
	@pivotX	@const @formula("(xStart < xEnd) ? -size : 0.0") 
	var px:Int;

	// texture tile number
	@texTile @const @formula("floor(mod(  ((xStart < xEnd) ? 1.0 : -1.0) *  x * 0.13 * 128.0/size , 23.0))")
	var tile:Int;
	
	var OPTIONS = { blend:true };

	public function new(y:Int, size:Int) {
		this.y = y;
		this.size = size;
	}
}
