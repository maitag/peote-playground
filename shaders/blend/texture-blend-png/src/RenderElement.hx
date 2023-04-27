package;

import peote.view.Element;

class RenderElement implements Element
{
	@posX public var x:Int;
	@posY public var y:Int;
	@sizeX public var w:Int;
	@sizeY public var h:Int;

	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		this.x = x;
		this.y = y;
		this.w = width;
		this.h = height;
	}
}