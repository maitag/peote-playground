package;

import peote.view.*;

class PixelElement implements Element {
	/** Position of the element on x axis. Relative to top left of Display.**/
	@posX public var x:Float;

	/** Position of the element on y axis. Relative to top left of Display.**/
	@posY public var y:Float;

	/** Size of the element on x axis. **/
	@sizeX @varying public var width:Int;

	/** Size of the element on y axis. **/
	@sizeY @varying public var height:Int;

	/** The pivot point around with the element will rotate on the x axis - 0.5 is the center. **/
	@pivotX @formula("width * pivot_x") public var pivot_x:Float = 0.0;

	/** The pivot point around with the element will rotate on the y axis - 0.5 is the center. **/
	@pivotY @formula("height * pivot_y") public var pivot_y:Float = 0.0;

	/** Degrees of rotation. **/
	@rotation public var angle:Float = 0.0;

	/** RGBA color. **/
	@color public var color:Color = 0xf0f0f0ff;

	/** Auto-enable blend in the Program the element is rendered by (for alpha and more) **/
	var OPTIONS = {blend: true};

	/** 
		@param x the starting x position in the Display.
		@param y the starting y position in the Display.
		@param width (optional) is 1 pixel by default.
		@param height (optional) is 1 pixel by default.
	**/
	public function new(x:Float, y:Float, width:Int = 1, height:Int = 1) {
		this.x = Std.int(x);
		this.y = Std.int(y);
		this.width = width;
		this.height = height;
	}

	/** 
		Skews the element to form a line. 
		@param thickness (optional) how many pixels thick is the line.
	**/
	public function to_line(x_start:Float, y_start:Float, x_end:Float, y_end:Float, thickness:Int = 1) {
		x = x_start;
		y = y_start;
		var a = x_start - x_end;
		var b = y_start - y_end;
		
		width = Std.int(Math.sqrt(a * a + b * b)) + height;
		height = thickness;
		angle = Math.atan2(x_end - x_start, -(y_end - y_start)) * (180 / Math.PI) - 90;
	}
}
