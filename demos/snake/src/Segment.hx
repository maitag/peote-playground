
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Display;
import peote.view.Element;
import peote.view.Program;

@:publicFields
class Segment implements Element
{
	/**
		position on x axis
	**/
	@posX public var x:Float;

	/**
		position on y axis
	**/
	@posY public var y:Float;

	/**
		width in pixels
	**/
	@varying @sizeX public var width:Int;

	/**
		height in pixels
	**/
	@varying @sizeY public var height:Int;

	/**
		pivot point of the element on x axis, e.g. 0.5 is the center
	**/
	@pivotX @formula("width * pivotX") var pivotX:Float = 0.0;

	/**
		pivot point of the element on y axis, e.g. 0.5 is the center
	**/
	@pivotY @formula("height * pivotY") var pivotY:Float = 0.0;

	/**
		rotation in degrees
	**/
	@rotation public var angle:Float = 0.0;

	/**
		tint the color of the Element, compatible with RGBA Int
	**/
	@color public var tint:Color;

	// enables alpha
	var OPTIONS = { blend: true };

	/**
	 * Instance a new Segment Element
	 * @param width how many pixels wide
	 * @param height how many pixels high
	 * @param tint Color the Element
	 * @param x pixel position of the Element on x axis
	 * @param y pixel position of the Element on y axis
	 * @param isCenterPivot when true the Element position is relative to the center of the Element (by default the Element position is top left corner)
	 */
	public function new(width:Float, height:Float, tint:Color = 0xffffffFF, x:Float = 0, y:Float = 0, isCenterPivot:Bool = false)
	{
		this.width = Std.int(width);
		this.height = Std.int(height);
		this.x = Std.int(x);
		this.y = Std.int(y);
		this.tint = tint;

		if (isCenterPivot)
		{
			this.pivotX = 0.5;
			this.pivotY = 0.5;
		}
	}
}

class SegmentBuffer extends Buffer<Segment>
{
	var program:Program;

	/**
	 * Instance a new buffer and program to put Segments in
	 * @param size the initial size of the buffer, the buffer will be resized by this amount automatically when it is filled
	 */
	public function new(size:Int)
	{
		super(size, size);
		program = new Program(this);
	}

	public function addToDisplay(display:Display)
	{
		display.addProgram(program);
	}
}
