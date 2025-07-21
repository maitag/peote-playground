class IsoPoint {
	public var column:Int;
	public var row:Int;
	public var x:Float;
	public var y:Float;

	public var widthMid:Float;
	public var heightMid:Float;

	public function new(rhombusWidth:Float, rhombusHeight:Float) {
		widthMid = rhombusWidth / 2;
		heightMid = rhombusHeight / 2;
		changeGrid(0, 0);
	}

	public function changeGrid(column:Int, row:Int) {
		this.column = column;
		this.row = row;
		x = (column - row) * widthMid;
		y = (column + row) * heightMid;
	}

	public function changeScreen(x:Float, y:Float) {
		this.x = x;
		this.y = y;
		column = Math.round((x / widthMid + y / heightMid) / 2);
		row = Math.round((y / heightMid - x / widthMid) / 2);
	}
}
