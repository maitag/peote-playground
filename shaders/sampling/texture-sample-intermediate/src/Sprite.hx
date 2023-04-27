package;

import peote.view.Element;
import peote.view.Color;

class Sprite implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;
	
	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	// rotation around pivot point
	@rotation public var r:Float;
	
	// pivot x (rotation offset)
	@pivotX @formula("w * 0.5 + px_offset") public var px_offset:Float = 0.0;

	// pivot y (rotation offset)
	@pivotY @formula("h * 0.5 + py_offset") public var py_offset:Float = 0.0;
	
	// color (RGBA)
	@color public var c:Color = 0xff0000ff;
	
	// z-index
	@zIndex public var z:Int = 0;	
	
	public function new(x:Int, y:Int, width:Int, height:Int, color:Color) {
		this.x = x;
		this.y = y;
		w = width;
		h = height;
		c = color;
	}
}
