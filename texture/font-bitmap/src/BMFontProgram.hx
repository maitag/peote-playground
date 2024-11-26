package;

import peote.view.Texture;
import peote.view.Program;
import peote.view.Buffer;
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
		this.y = y;
		this.w = w;
		this.h = h;
		this.fgColor = fgColor;
		this.bgColor = bgColor;
		this.tile = tile;
	}
}


class BMFontProgram extends Program {

	public var buff(get, never):Buffer<Glyph>;
	inline function get_buff() return cast this.buffer;

	public function new(font:BMFontData, ?options:BMFontOptions, minBufferSize:Int = 1024 , growBufferSize:Int = 1024)
	{
		if (options == null) options = {};		

		super( new Buffer<Glyph>(minBufferSize , growBufferSize) );

		var texture = Texture.fromData(font.textureData);

		texture.tilesX = font.length;
		texture.tilesY = 1;

		addTexture(texture, "base", false);

		setColorFormula("( base.r > 0.0) ? fgColor : bgColor");
	}

}
