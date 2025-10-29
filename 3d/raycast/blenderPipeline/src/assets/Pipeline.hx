package assets;

enum abstract Pipeline(Int) from Int to Int {
	var Brilliant = 5;
	var Cone = 2;
	var Cube = 0;
	var CubeBorder = 8;
	var Diamond = 6;
	var Gem = 4;
	var Human = 7;
	var Icosphere = 1;
	var Suzanne = 3;

	public static var fileName:String = "assets/pipeline.png";
	public static var width:Int = 1024;
	public static var height:Int = 705;
	public static var tilesX:Int = 4;
	public static var tilesY:Int = 3;
	public static var tileWidth:Int = 256;
	public static var tileHeight:Int = 235;
	public static var gap:Int = 0;
	public static var degrees:Int = 12;
}