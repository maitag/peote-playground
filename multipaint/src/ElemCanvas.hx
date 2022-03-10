package;

import peote.view.Element;
import peote.view.Color;

class ElemCanvas implements Element
{
	@sizeX public var w:Float;	
	@sizeY public var h:Float;
	
	public function new(w:Float, h:Float)
	{
		this.w = w;
		this.h = h;
	}
}
