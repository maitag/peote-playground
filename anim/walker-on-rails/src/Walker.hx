package;

import Math;
import peote.view.Element;
import peote.view.Color;

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
	@texTile @const @formula("floor(mod(  ((xStart < xEnd) ? 1.0 : -1.0) *  x * 0.15 * 128.0/size , 23.0))")
	var tile:Int;

	@color var c:Color;
	
	var OPTIONS = { blend:true };

	public function new(y:Int, color:Color, size:Int) {
		this.y = y;
		this.c = color;
		this.size = size;
	}

	public function goLeft(way:Int, duration:Float) {
		animX(way, -size);
		timeX(0.0, duration);
	}

	public function goRight(way:Int, duration:Float) {
		animX(-size, way);
		timeX(0.0, duration);
	}

	public function goLeftOrRight(way:Int, duration:Float) {
		if (Math.random() < 0.5) goLeft(way, duration) else goRight(way, duration);
	}

}
