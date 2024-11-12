package;

import peote.view.Element;
import peote.view.Color;

class Glyph implements Element {
	// position in pixel
	@posX public var x:Float;
	@posY public var y:Float;

	// size in pixel
	@sizeX public var width:Int;
	@sizeY public var height:Int;

	// color (RGBA)
	@color public var color:Color = 0xf0f0f0ff;
	
	// index of glyph in texture
	@texTile public var tile_index:Int;

	public function new(x:Float, y:Float, size:Float, index:Int) {
		this.x = Std.int(x);
		this.y = Std.int(y);
		width = Std.int(size);
		height = Std.int(size);
		tile_index = index;
	}
}