package;

import peote.view.*;

class TwoSliceElement implements Element {
	@posX public var x:Int = 0;
	@posY public var y:Int = 0;
	@sizeX public var w:Int = 0;
	@sizeY public var h:Int = 0;
	@color public var tint:Color= 0xffffffFF;

	/**
		size of repeated tile on y axis
	**/
	@varying @custom @formula("h / tileHeight") public var tileHeight:Float;

	@varying @texTile() var tile_index:Int;

	var OPTIONS = {blend: true};

	public function new(tileHeight:Int, tileIndex:Int) {
		this.tileHeight = tileHeight;
		this.tile_index = tileIndex;
	}

	public static function makeProgram(texture:Texture, tilesX:Int, tilesY:Int, buffer:Buffer<TwoSliceElement>, uniqueId:String):Program {
		var program = new Program(buffer);
		texture.tilesX = tilesX;
		texture.tilesY = tilesY;
		program.addTexture(texture, uniqueId);

		// repeating texture by tile height
		program.setColorFormula('getTextureColor( ${uniqueId}_ID, fract(vTexCoord * vec2(1.0, tileHeight)) ) * tint');
		return program;
	}
}