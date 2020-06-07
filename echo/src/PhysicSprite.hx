package;

import peote.view.Buffer;
import peote.view.Element;
import peote.view.Color;

import echo.World;
import echo.Body;
import echo.data.Options.BodyOptions;

class PhysicSprite implements Element
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
	
	
	public var body:Body;
	
	public function new(buffer:Buffer<PhysicSprite>, color:Color, world:World, options:BodyOptions)
	{
		this.color = color;
		
		width = options.shape.width;
		height = options.shape.height;
		
		pivotX = width / 2;
		pivotY = height / 2;

		x = options.x - pivotX;
		y = options.y - pivotY;
		
		if (options.rotation != null) rotation = options.rotation;
		
		body = world.make(options);
		
		body.on_move = onMove.bind(buffer, _);
		body.on_rotate = onRotate.bind(buffer, _);
		
		buffer.addElement(this);
	}
	
	public function onMove(buffer: Buffer<PhysicSprite>, x:Float, y:Float)
	{
		setPosition(x - pivotX, y - pivotY);
		buffer.updateElement(this);
	}
	
	public function onRotate(buffer: Buffer<PhysicSprite>, rotation:Float) 
	{
		//trace("onRotate", rotation);
		this.rotation = rotation;
		buffer.updateElement(this);
	}
	
}
