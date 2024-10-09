import peote.view.*;

@:publicFields
class Shape implements Element {
	@posX public var x:Float;
	@posY public var y:Float;

	@varying @sizeX public var width:Int;
	@varying @sizeY public var height:Int;

	/**
		pivot point of the element on x axis, e.g. 0.5 is the center
	**/
	@pivotX @formula("width * pivot_x") var pivot_x:Float = 0.5;

	/**
		pivot point of the element on y axis, e.g. 0.5 is the center
	**/
	@pivotY @formula("height * pivot_y") var pivot_y:Float = 0.5;

	/**
		rotation in degrees
	**/
	@rotation public var angle:Float = 0.0;

	/**
		tint the color of the Element, compatible with RGBA Int
	**/
	@color public var tint:Color;

	var OPTIONS = {blend: true};

	public function new(x:Float, y:Float, width:Float, height:Float, tint:Color) {
		this.x = Std.int(x);
		this.y = Std.int(y);

		this.width = Std.int(width);
		this.height = Std.int(height);

		this.tint = tint;
	}
}
