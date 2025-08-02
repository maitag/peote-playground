package rays;

import peote.view.*;

@:publicFields
class Ray implements Element {
	@posX var x_a:Int;
	@posY var y_a:Int;
	var x_b:Int;
	var y_b:Int;

	// calculated pivot
	@pivotX @formula("thick * 0.5") var px:Int;
	@pivotY @formula("thick * 0.5") var py:Int;

	// rotation around pivot point
	@rotation private var angle:Float;

	@sizeX var length:Int = 1;
	@sizeY var thick:Int = 1;
	@color var tint:Color;

	var OPTIONS = {blend: true};

	function new(x_a:Float, y_a:Float, x_b:Float, y_b:Float, thick:Float, tint:Int) {
		this.thick = Std.int(thick);
		this.tint = tint;

		this.x_a = Std.int(x_a);
		this.y_a = Std.int(y_a);
		this.x_b = Std.int(x_b);
		this.y_b = Std.int(y_b);

		rotate();
	}
	/*
	inline function set_start(x:Float, y:Float) {
		this.x_a = Std.int(x);
		this.y_a = Std.int(y);
		rotate();
	}

	inline function set_end(x:Float, y:Float) {
		this.x_b = Std.int(x);
		this.y_b = Std.int(y);
		rotate();
	}
*/
	inline private function rotate() {
		var a = x_a - x_b;
		var b = y_a - y_b;

		length = Std.int(Math.sqrt(a * a + b * b)); // + thick;
		angle = Math.atan2(x_b - x_a, -(y_b - y_a)) * (180 / Math.PI) - 90;
	}
}
