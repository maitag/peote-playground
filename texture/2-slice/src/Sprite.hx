import peote.view.*;

@:publicFields
class Sprite {
	var x(default, set):Float;
	var y(default, set):Float;
	var width(default, set):Float;
	var height(default, set):Float;

	private var top:TwoSliceElement;
	private var bottom:TwoSliceElement;
	private var isReady:Bool = false;

	public function new(x:Int, y:Int, index:Int, width:Int, height:Int, tileHeight:Int, tilesY:Int) {
		top = new TwoSliceElement(tileHeight, index);
		bottom = new TwoSliceElement(tileHeight, index + tilesY);
		// tint bottom so it's visible
		bottom.tint.a = 0x80;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public function addTo(buffer:Buffer<TwoSliceElement>) {
		buffer.addElement(top);
		buffer.addElement(bottom);
	}

	function set_x(value:Float):Float {
		top.x = Std.int(value);
		bottom.x = Std.int(value);
		return value;
	}

	function set_y(value:Float):Float {
		top.y = Std.int(value);
		bottom.y = Std.int(top.y + top.h);
		return value;
	}

	function set_width(value:Float):Float {
		top.w = Std.int(value);
		bottom.w = Std.int(value);
		return value;
	}

	function set_height(value:Float):Float {
		top.h = Std.int(value - bottom.tileHeight);
		bottom.h = Std.int(bottom.tileHeight);
		bottom.y = top.y + top.h;
		return value;
	}
}
