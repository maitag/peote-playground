package;

import peote.view.Element;
import peote.view.Color;

class TurboLine implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;
	
	// size in pixel
	@sizeX public var w(default, null):Int;
	@sizeY @const var h:Int = 1;
	
	// rotation around pivot point
	@rotation var r:Float;
	
	// color (RGBA)
	@color public var c:Color = 0xf6871fFF;
	
/*	// pivot x (rotation offset)
	@pivotX public var px:Int = 0;

	// pivot y (rotation offset)
	@pivotY public var py:Int = 0;
*/	
	
	public function new(x0:Int, y0:Int, x1:Int, y1:Int) {
		set(x0, y0, x1, y1);
	}

	public function set(x0:Int, y0:Int, x1:Int, y1:Int) {
		x = x0;
		y = y0;
		var a = x0 - x1;
		var b = y0 - y1;	
		w = Std.int( Math.sqrt( a * a + b * b ) );
		r = Math.atan2(x1 - x0, - (y1 - y0) )*(180 / Math.PI) - 90; // thx to halfwheat \o/
	}
}
