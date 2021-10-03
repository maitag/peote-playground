package;

import peote.view.Element;
import peote.view.Color;

class LineSegment implements Element
{
	// start-point of the line
	@posX public var xStart:Int=0;
	@posY public var yStart:Int = 0;
	
	// end-point of the line (2 new custom vbuffer attributes)
	@custom public var xEnd:Int=0;
	@custom public var yEnd:Int=0;

	// line height
	@sizeY public var h:Int = 1;
	
	// calculating the pivot point by formulas on gpu
	@pivotX @const @formula("0.0") public var px:Int;
	@pivotY @const @formula("h/2.0") public var py:Int;
	

	
	// ----------------------------------------------------------

	// calculating on gpu into depend of start and endpoint
	@sizeX @const @formula("sqrt( (xStart-xEnd)*(xStart-xEnd) + (yStart-yEnd)*(yStart-yEnd) )") public var w:Int;

	// T O D O :
	
	// rotation around pivot point
	@rotation public var r:Float;
	
	
	
	// ----------------------------------------------------------
	
	// color (RGBA)
	@color public var c:Color = 0xff0000ff;
	
	// z-index
	@zIndex public var z:Int = 0;	
	
	public function new() {}
}
