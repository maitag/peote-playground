package;

import peote.view.Color;

typedef Colorband = Array<ColorbandItem>;

@:structInit 
class ColorbandItem
{
	public var color:Color = null;
	public var size:Null<Int> = null;
	public var smoothPrev:Float = 0.0;
	public var smoothNext:Float = 0.0;
}
