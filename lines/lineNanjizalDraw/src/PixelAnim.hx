import peote.view.Color;
import peote.view.Element;

class PixelAnim implements Element{
	
	// interpolation can be "constant", "repeat" or "pingpong" also!
	@posX @anim("Position", "constant") public var x:Int;
	@posY @anim("Position") public var y:Int;

	// width and height (constantly 1)
	@sizeX @const public var w:Int = 1;
	@sizeY @const public var h:Int = 1;

	// rgba
	@color public var c:Color;

	public function new(x:Int, y:Int, color:Color)
	{
		// set the end-coordinates to outer screen
		var xOutOfScreen = x + ( 128 - Std.random(256) );
		var yOutOfScreen = y + ( 128 - Std.random(256) );
		
		animPosition(x, y, xOutOfScreen, yOutOfScreen);
		timePosition(0.0, 1.0); // from start-time (0.0) and during 1.0 second
		
		this.c = color;
	}
}