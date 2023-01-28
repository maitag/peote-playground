import peote.view.Color;
import peote.view.Element;

class Pixel implements Element{
	@posX public var x:Int;
	@posY public var y:Int;

	// width and height (constantly 1)
	@sizeX @const public var w:Int = 1;
	@sizeY @const public var h:Int = 1;

	// rgba
	@color public var c:Color;

	public function new(x:Int, y:Int, color:Color){
		this.x = x;
		this.y = y;
		this.c = color;
	}
}