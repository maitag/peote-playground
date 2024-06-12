package;

import peote.view.*;

class ElementTentacle implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int = 0;
	@posY public var y:Int = 0;
	
	@varying @custom public var depth:Float = 0.0;
	
	// size in pixel
	@sizeX public var w:Int = 128;
	@sizeY public var h:Int = 128;
	
	@varying @rotation public var r:Float = 0.0;

	// pivot point for rotation
	@pivotX var px:Int = 0;
	@pivotY var py:Int = 0;

	// var OPTIONS = { texRepeatX:true, texRepeatY:true };

	// --------------------------------------------------------------------------
	
	public function new(x:Int = 0, y:Int = 0, w:Int = 128, h:Int = 128, r:Float = 0.0, px:Int = 0, py:Int = 0)
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;

		// if element is flipped by negative size, this hack makes the rotation negative to mirror the normals:
		if (w < 0 && r>=0.0) {
			r = -360 + r%360;
		}
		this.r = r;

		this.px = px;
		this.py = py;
	}

}
