package;

import peote.view.Element;
import peote.view.Color;

class PointParticle implements Element
{
	// ------------ INPUTS --------------
	
	// coords for spawn point 
	@custom public var ex:Int = 0;
	@custom public var ey:Int = 0;

	// color (RGBA)
	@color public var c:Color = 0xff0000ff;

	// seed to use in shader formulas
	@custom public var s:Int = 0;

	// timeDiff to use in shader formulas
	@custom public var t:Int = 0;
	
	// -----------------------------------

	// calculated by shader
	@posX  @const var x:Float = 0.0;
	@posY  @const var y:Float = 0.0;	
	@sizeX @const var w:Float = 10.0;
	@sizeY @const var h:Float = 10.0;

	// pivot always into the middle
	@pivotX @const @formula("w*0.5") var px:Float;
	@pivotY @const @formula("h*0.5") var py:Float;
	

	// -----------------------------------

	public function new(ex:Int, ey:Int, color:Color, seed:Int, timeDiff:Int) {
		this.ex = ex;
		this.ey = ey;
		c = color;
		s = seed;
		t = timeDiff;
	}
}
