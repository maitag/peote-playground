package;

import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Element;
import peote.view.Color;

import echo.World;
import echo.Body;
import echo.math.Vector2;
import echo.data.Options.BodyOptions;

class Rectangle implements Element
{
	// position in pixel (relative to upper left corner of Display)
	//@posX @anim("Position") public var x:Float = 0.0;
	//@posY @anim("Position") public var y:Float = 0.0;
	@posX @set("Position") public var x:Float = 0.0;
	@posY @set("Position") public var y:Float = 0.0;
	
	// size in pixel
	@sizeX public var width:Float;
	@sizeY public var height:Float;
	
	// rotation around pivot point
	@rotation public var rotation:Float = 0.0;
	
	// pivot x (rotation offset)
	@pivotX public var pivotX:Float = 0.0;

	// pivot y (rotation offset)
	@pivotY public var pivotY:Float = 0.0;
	
	// color (RGBA)
	@color public var color:Color = 0x000000ff;
	
	// z-index
	// @zIndex public var z:Int = 0;	
	
	// -------------------------------------------------------
	static var buffer:Buffer<Rectangle>;
	static var program:Program;

	static var world:World;

	public static function init(world:World) {
		Rectangle.world = world;
		buffer = new Buffer<Rectangle>(1024, 1024, true);
		program = new Program(buffer);
	}

	public static function addToDisplay(display:Display) display.addProgram(program);
	public static function removeFromDisplay(display:Display) display.removeProgram(program);

	public static var borderWidth:Int = 800;
	public static var borderHeight:Int = 600;
	public static function resize(width:Int, height:Int) {
		borderWidth = width;
		borderHeight = height;
	}

	
	// -------------------------------------------------------
	public var body:Body; // <- bridge to the echo-physic body
	
	public function new(color:Color, options:BodyOptions)
	{
		this.color = color;
		
		width = options.shape.width;
		height = options.shape.height;
		
		pivotX = width / 2;
		pivotY = height / 2;

		x = options.x;// - pivotX;
		y = options.y;// - pivotY;
		
		if (options.rotation != null) rotation = options.rotation;
		
		body = world.make(options);
		
		if (options.mass != 0) {
			body.on_move = _onMove;
			body.on_rotate = _onRotate;
		}

		buffer.addElement(this);
	}
	
	function _onMove( x:Float, y:Float)
	{
		if (x == body.last_x && y == body.last_y) return;
		// trace("_onMove", x, y);

		// --------------- bounce at border ----------------
		if (body.velocity.x < 0) {
			if (x - body.bounds().width/2.0 < 0) {
				body.velocity = new Vector2(-body.velocity.x, body.velocity.y);
				// body.x = body.bounds().width/2.0;
			}
		}
		else if (x + body.bounds().width/2.0 > borderWidth) {
			body.velocity = new Vector2(-body.velocity.x, body.velocity.y);
			// body.x = borderWidth - body.bounds().width/2.0;
		}

		if (body.velocity.y < 0) {
			if (y - body.bounds().height/2.0 < 0) {
				body.velocity = new Vector2(body.velocity.x, -body.velocity.y);
				// body.y = body.bounds().height/2.0;
			}
		}
		else if (y + body.bounds().height/2.0 > borderHeight) {
			body.velocity = new Vector2(body.velocity.x, -body.velocity.y);
			// body.y = borderHeight - body.bounds().height/2.0;
		}

		setPosition(body.x, body.y);
		
		buffer.updateElement(this);
	}
	
	function _onRotate(rotation:Float) 
	{
		if (rotation == body.last_rotation) return;
		// trace("onRotate", rotation);
		this.rotation = rotation;
		buffer.updateElement(this);
	}
	
}
