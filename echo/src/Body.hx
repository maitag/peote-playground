package;

import peote.view.Element;
import peote.view.Color;

class Body implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX @anim("Position") public var x:Int=0;
	@posY @anim("Position") public var y:Int=0;
	
	// size in pixel
	@sizeX public var width:Int=100;
	@sizeY public var height:Int=100;
	
	// rotation around pivot point
	@rotation public var rotation:Float;
	
	// pivot x (rotation offset)
	@pivotX public var pivotX:Int = 0;

	// pivot y (rotation offset)
	@pivotY public var pivotY:Int = 0;
	
	// color (RGBA)
	@color public var color:Color = 0x000000ff;
	
	// z-index
	// @zIndex public var z:Int = 0;	
	
	public function new() {}
}
