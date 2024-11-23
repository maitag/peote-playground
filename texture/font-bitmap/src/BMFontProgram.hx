package;

import peote.view.Program;
import peote.view.Element;
import peote.view.Color;

class Glyph implements Element {
	@posX public var x:Int;
	@posY public var y:Int;
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	@color public var fgColor:Color = 0xf0f0f0ff;
	@color public var bgColor:Color = 0;
	@texTile public var tile:Int;

	public function new(x:Int, y:Int, w:Int, h:Int, fgColor:Color, bgColor:Color, tile:Int) {
		this.x = x;
		this.y = x;
		this.w = w;
		this.h = h;
		this.fgColor = fgColor;
		this.bgColor = bgColor;
		this.tile = tile;
	}
}


// T O D OOOOOOOOO

class BMFontProgram extends Program {
/*
	public function new(font:BMFontData, options:BMFontProgramOptions)
	{

		super( new Buffer<Glyph>() );
	}
*/
}
