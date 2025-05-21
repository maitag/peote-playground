import lime.math.Vector2;
import peote.view.Buffer;
import Segment;
import Util;

@:structInit
@:publicFields
class SnakeOptions
{
	/**
	 * size of the grid cell to align snake movement
	 */
	var gridQuantise:Int;

	/**
	 * width of the grid the snake is in
	 */
	var columns:Int;

	/**
	 * height of the grid the snake is in
	 */
	var rows:Int;

	/**
	 * hoiw many body segments the snake starts with
	 */
	var initialSegments:Int;

	var headColor:RGB;
	var bodyColor:RGB;
}

class Snake
{
	public var options(default, null):SnakeOptions;
	public var isAlive:Bool = true;

	var buffer:Buffer<Segment>;
	var currentDirection:Direction = LEFT;
	var nextDirection:Direction = LEFT;

	var head:Segment;
	public var body(default, null):Array<Segment> = [];
	var positionHistory:Array<Vector2> = [];

	public var x(get, never):Float;
	public var y(get, never):Float;

	function get_x():Float
	{
		return head.x;
	}

	function get_y():Float
	{
		return head.y;
	}

	public function new(x:Float, y:Float, options:SnakeOptions, buffer:Buffer<Segment>)
	{
		this.options = options;
		this.buffer = buffer;

		for (n in 0...options.initialSegments)
		{
			addBodySegment();
		}

		head = initSegment(x, y, options.gridQuantise - 2, options.headColor);
		positionHistory.push(new Vector2(head.x, head.y));
	}

	/**
	 * Instance a new Segment element and add it to the buffer
	 * @param x the display position on x axis
	 * @param y the display position on y axis
	 * @param size the size of the element (it's square)
	 * @param color optionally pass a color to override the color set in SnakeOptions
	 * @return Segment
	 */
	function initSegment(x:Float, y:Float, size:Int, color:RGB = null):Segment
	{
		var segmentColor = color ?? options.bodyColor;
		return buffer.addElement(new Segment(size, size, segmentColor, x, y, true));
	}

	/**
	 * Change the snake head and body segment positions
	 */
	public function move()
	{
		// body segments will follow the position history so put current head position at the start
		positionHistory.unshift(new Vector2(head.x, head.y));

		// now there are too many positions so trim the history according to the segment count
		if (positionHistory.length > body.length)
		{
			positionHistory.pop();
		}

		// reposition head according to direction of travel
		switch nextDirection
		{
			case LEFT:
				head.x -= options.gridQuantise;
			case RIGHT:
				head.x += options.gridQuantise;
			case UP:
				head.y -= options.gridQuantise;
			case DOWN:
				head.y += options.gridQuantise;
			case _:
		}
		currentDirection = nextDirection;

		// wrap position to boundary
		var col = Std.int(head.x / options.gridQuantise);
		var row = Std.int(head.y / options.gridQuantise);
		if (col < 0)
		{
			col = options.columns;
		}
		if (col > options.columns)
		{
			col = 0;
		}
		if (row < 0)
		{
			row = options.rows;
		}
		if (row > options.rows)
		{
			row = 0;
		}
		head.x = col * options.gridQuantise;
		head.y = row * options.gridQuantise;

		// update the segment positions
		for (i in 0...positionHistory.length)
		{
			body[i].x = positionHistory[i].x;
			body[i].y = positionHistory[i].y;
		}
	}

	/**
	 * Change the direction the snake is traveling.
	 * @param direction the desired new direction of travel
	 */
	public function steerHead(direction:Direction)
	{
		// when the direction is opposite to the current direction, ignore the change
		// this prevents the snake traveling back along itself
		switch [currentDirection, direction]
		{
			case [LEFT, RIGHT]:
				return;
			case [RIGHT, LEFT]:
				return;
			case [UP, DOWN]:
				return;
			case [DOWN, UP]:
				return;
			case _:
				nextDirection = direction;
		}
	}

	/**
	 * Check if the head is overlapping a position. Quantised to the game grid.
	 * @param x the position on x axis on the display
	 * @param y the position on y axis on the display
	 * @return Bool
	 */
	public function isHeadOverlap(x:Float, y:Float):Bool
	{
		var headCol = head.x / options.gridQuantise;
		var headRow = head.y / options.gridQuantise;

		var overlapCol = x / options.gridQuantise;
		var overlapRow = y / options.gridQuantise;

		return headCol == overlapCol && headRow == overlapRow;
	}

	/**
	 * Add a body segment
	 */
	public function addBodySegment()
	{
		body.push(initSegment(-20, -20, options.gridQuantise - 2));
	}
}
