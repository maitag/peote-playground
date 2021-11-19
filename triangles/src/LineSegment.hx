package;

import peote.view.Element;
import peote.view.Color;

class LineSegment implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x0:Float;
	@posY public var y0:Float;
	
	public var x1:Float;
	public var y1:Float;
	
	public var x2:Float;
	public var y2:Float;
	
	
	// calculated size in pixel
	@sizeX public var w:Float;
	@sizeY public var h:Float;
	
	// calculated rotation around (x0, y0)
	@rotation var r:Float;
	
	
	// color (RGBA)
	@color public var c:Color = 0xff0000ff;
	
	
	// z-index
	@zIndex public var z:Int = 0;
	
	
	public function new(
		x0:Float, y0:Float, 
		x1:Float, y1:Float, 
		x2:Float, y2:Float, c:Color
	)
	{
		this.x0 = x0; this.y0 = y0;
		this.x1 = x1; this.y1 = y1;
		this.x2 = x2; this.y2 = y2; this.c = c;
		update();
	}
	
	public function update()
	{		
		var a = x0 - x1;
		var b = y0 - y1;			
		w = Math.sqrt( a * a + b * b );
			
		r = Math.atan2(x1 - x0, - (y1 - y0) )*(180 / Math.PI) - 90;
		
		h = ( x0*(y1-y2) + x1*(y2-y0) + x2*(y0-y1) ) / w;
		
	}
}
