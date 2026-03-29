package;

import peote.view.Buffer;
import peote.view.Element;
import peote.view.Color;
import PipelineTools.Tile;
import PipelineTools.Anim;

class ElemAnim implements Element
{
	// position in pixel
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	// size in pixel
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	// rotation around pivot point
	@rotation public var r:Float;
	
	// pivot x (rotation offset)
	@pivotX public var px:Int = 0;

	// pivot y (rotation offset)
	@pivotY public var py:Int = 0;
	
	// color (RGBA)
	@color public var c:Color = 0xffffffff;
	
	// z-index
	@zIndex public var z:Int = 0;

	// texture unit (sheet index!)
	@texUnit public var sheetIndex:Int=0;

	// @texSlot public var slot:Int = 0;

	// animatable tile-number into sheet
	@anim("Tile") @texTile public var tileIndex:Int = 0;

	public static var buffer:Buffer<ElemAnim>;
	public static var tiles:Map<String, Tile>;
	public static function init(_buffer:Buffer<ElemAnim>, _tiles:Map<String, Tile>) {
		buffer = _buffer;
		tiles = _tiles;
	}


	var tile:Tile;

	public function new(x:Int, y:Int, tileName:String) {
		this.x = x;
		this.y = y;
		tile = tiles.get(tileName);
		w = tile.width;
		h = tile.height;
		sheetIndex = tile.sheetIndex;
		buffer.addElement(this);
	}

	public function play(animName:String, startTime:Float, duration:Float) {
		var anim = tile.anim.get(animName);
		animTile(anim.start, anim.end);
		timeTileStart = startTime;
		timeTileDuration = duration;
		buffer.updateElement(this);
	}
}
