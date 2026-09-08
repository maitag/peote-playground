package asset;

@:structInit @:publicFields class Sheet {
	var name:String;
	var width:Int;
	var height:Int;
	var gap:Int;
	var tilesX:Int;
	var tilesY:Int;
	public function new(n:String, w:Int, h:Int, g:Int, tx:Int, ty:Int) {
		name = n;
		width = w;
		height = h;
		gap = g;
		tilesX = tx;
		tilesY = ty;
	}
}
