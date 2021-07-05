package;

import peote.view.Element;
import peote.view.Color;

class Semmi implements Element
{
	@sizeX @const public var w:Int=60;
	@sizeY @const public var h:Int=64;
	
	@posX @constStart(0) @constEnd(800) @anim("X","pingpong") @formula("xStart+(xEnd-w-xStart)*time0") public var x:Int;
	@posY @constStart(0) @constEnd(600) @anim("Y","pingpong") @formula("yStart+(yEnd-h-yStart)*time1*time1") public var y:Int;

	public function new(x:Int, y:Int, currTime:Float) {
		this.timeX(currTime, 10);
		this.timeY(currTime, 3);
	}

}
