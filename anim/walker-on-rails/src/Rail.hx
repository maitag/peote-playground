package;

import Math;
import peote.view.Element;
import peote.view.Color;

class Rail implements Element
{
	@const var x:Int = 0;

	@posY public var y:Int;	
	@sizeX public var size:Int;
	@color public var c:Color;

	public function new(y:Int, color:Color, size:Int) {
		this.y = y;
		this.c = color;
		this.size = size;
	}
}
