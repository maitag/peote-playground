class IsoPoint {
	public var column:Int;
	public var row:Int;
	public var x:Float;
	public var y:Float;

	public var halfWidth:Float;
	public var halfHeight:Float;

	public function new(rhombusWidth:Float, rhombusHeight:Float) {
		halfWidth = rhombusWidth / 2;
		halfHeight = rhombusHeight / 2;
		changeGrid(0, 0);
	}

	public function changeGrid(column:Int, row:Int) {
		this.column = column;
		this.row = row;
		x = (column - row) * halfWidth;
		y = (column + row) * halfHeight;
	}

	public function changeScreen(x:Float, y:Float) {
		this.x = x;
		this.y = y;
		column = Math.round((x / halfWidth + y / halfHeight) / 2);
		row = Math.round((y / halfHeight - x / halfWidth) / 2);
	}
}
