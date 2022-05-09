package;

import peote.view.Color;

typedef Colorband = Array<ColorbandItem>;

@:structInit 
class ColorbandItem
{
	public var color:Color;
	public var size:Null<Int> = null;
	public var interpolate:Interpolate = null;
}

