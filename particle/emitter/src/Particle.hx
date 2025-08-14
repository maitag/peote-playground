package;

import peote.view.Element;
import peote.view.Color;

class Particle implements Element
{
	// ------------ INPUTS --------------
	
	// coords for emitter spawn point 
	@custom public var ex:Int = 0;
	@custom public var ey:Int = 0;

	// overall size of a particle
	@custom public var size:Int = 10;

	// sizes (how far particle goes away from spawn point) 
	@custom public var sx:Int = 0;
	@custom public var sy:Int = 0;

	// color start and end (RGBA)
	@color public var cs:Color = 0xff0000ff;
	@color public var ce:Color = 0x0000ffff;

	// seed to use in shader formulas
	@custom @formula("seed") public var seed:Int = 0;

	// how many milliseconds "t" is need to travel from 0.0 up to 1.0
	@custom public var duration:Int = 0;

	// time to use in shader formulas (from 0.0 up to 1.0)
	@varying @custom public var t:Float = 0.0;
	
	// ------ CONST for FORMULAS ---------
	@custom @const var a:Float; // angle to go
	@custom @const var d:Float; // distance from spawnpoint

	// calculated by shader
	@posX  @const var x:Float = 0.0;
	@posY  @const var y:Float = 0.0;	
	@sizeX @const var w:Float = 10.0;
	@sizeY @const var h:Float = 10.0;

	// pivot always into the middle
	@pivotX @const @formula("w*0.5") var px:Float;
	@pivotY @const @formula("h*0.5") var py:Float;
	

	// -----------------------------------

	public function new(ex:Int, ey:Int, size:Int, sx:Int, sy:Int, colorStart:Color, colorEnd:Color, spawnTime:Float, duration:Int, seed:Int) {
		this.ex = ex;
		this.ey = ey;
		this.size = size;
		this.sx = sx;
		this.sy = sy;
		cs = colorStart;
		ce = colorEnd;
		t = spawnTime;
		this.duration = duration;
		this.seed = seed;
	}
}
