package rays;

import peote.view.Element;
import peote.view.Color;

class RayCone implements Element {
	@posX var x_a:Int;
	@posY var y_a:Int;
	var x_b:Int;
	var y_b:Int;

	@sizeX var length:Int;
	@sizeY @formula("thick - thick * (1.0-aPosition.x)") public var thick:Int;
	// @sizeY @formula("thick * ( 1.0 - (1.0-aPosition.x)") public var thick:Int;
	// @sizeY @formula("thick * ( -aPosition.x)") public var thick:Int;
	@pivotY @const @formula("thick/2.0") var _py:Int;

	@rotation private var angle:Float;

	@color var tint:Color;

	// var OPTIONS = {blend: true};

	public function new(x_a:Float, y_a:Float, x_b:Float, y_b:Float, thick:Float, tint:Int) {
		this.thick = Std.int(thick);
		this.tint = tint;

		this.x_a = Std.int(x_a);
		this.y_a = Std.int(y_a);
		this.x_b = Std.int(x_b);
		this.y_b = Std.int(y_b);

		rotate();
	}

	inline private function rotate() {
		var a = x_a - x_b;
		var b = y_a - y_b;

		length = Std.int(Math.sqrt(a * a + b * b)); // + thick;
		angle = Math.atan2(x_b - x_a, -(y_b - y_a)) * (180 / Math.PI) - 90;
	}
}
