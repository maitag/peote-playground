package;

import peote.view.Element;
import peote.view.Color;

class Sprite implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
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
	@color public var c:Color = 0xff0000ff;
	
	// z-index
	@zIndex public var z:Int = 0;	

	var OPTIONS = {blend: true};
	
	public function new(x:Int=0, y:Int=0, w:Int=100, h:Int=100, c:Color = Color.RED) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.c = c;
	}
}
