package;

import peote.view.Element;
import peote.view.Color;

class Particle implements Element
{
	// INPUT: angle from center of circle ( maybe into radians? )
	@custom public var a:Float = 0.0;

	// INPUT: distance from center of circle
	@custom public var d:Float = 100.0;


	// calculated by shader (formula is set inside DisplayRings Programs)
	@posX @const var x:Float;
	@posY @const var y:Float;
	
	
	// size and pivot (values will be hardcoded inside shadercode)
	@sizeX  @const var w:Float = 5.0;
	@sizeY  @const var h:Float = 5.0;
	@pivotX @const var px:Float = 2.5;
	@pivotY @const var py:Float = 2.5;
	
	// color (RGBA)
	@color public var c:Color = 0xff0000ff;
	
	static var degrees_to_radians = - Math.PI / 180;
	public function new(angle:Float, distance:Float) {
		a = angle * degrees_to_radians;
		d = distance;
	}
}
