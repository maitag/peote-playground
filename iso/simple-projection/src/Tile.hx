import peote.view.*;

@:publicFields
class Tile implements Element {
	/**
		position on x axis
	**/
	@posX var x:Int;

	/**
		position on y axis
	**/
	@posY var y:Int;

	/**
		width in pixels
	**/
	@sizeX var width:Int;

	/**
		height in pixels
	**/
	@sizeY var height:Int;

	/**
	 * which slot of tiles (refers to texture slot)
	 */
	@texSlot var slot:Int = 0;

	/**
	 * which tile in the bank
	 */
	@texTile var tile:Int = 0;

	/**
	 * what RGBA color to tint the tile
	 */
	@color var tint:Color = 0xffffffFF;

	var OPTIONS = {blend: true};

	function new(x:Float = 0, y:Float = 0, width:Float, height:Float, tile:Int = 0, ) {
		this.x = Std.int(x);
		this.y = Std.int(y);
		this.width = Std.int(width);
		this.height = Std.int(height);
		this.tile = tile;
	}
}
