package;

import peote.view.Element;
import peote.view.Color;

class AnimColPosSprite implements Element
{
	// position
	@posX @anim("Pos") public var x:Int=0;
	@posY @anim("Pos") public var y:Int=0;
	
	// color
	@color @anim("Col") public var c:Color = 0xff0000ff;
	

	// ----------------------
	
	// non animated and also constant size by shader for all Elements into Buffer:
	@sizeX @const var width:Int=100;
	@sizeY @const var height:Int=100;
	
	
	public function new() {}
}
