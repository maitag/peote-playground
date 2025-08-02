package;

import peote.view.Element;
import peote.view.Color;

import echo.Body;

class Rect implements Element implements XYR_Interface
{
	@posX @set("Position") public var x:Float = 0.0;
	@posY @set("Position") public var y:Float = 0.0;
	
	@sizeX public var width:Float;
	@sizeY public var height:Float;
	
	@rotation public var r:Float = 0.0;
	
	@pivotX public var pivotX:Float = 0.0;
	@pivotY public var pivotY:Float = 0.0;
	
	@color public var color:Color = 0x000000ff;
	
	// z-index
	// @zIndex public var z:Int = 0;	
	
	
	// -------------------------------------------------------
	public var body:Body; // <- bridge to the echo-physic body
	
	public function new(body:Body, width:Float, height:Float, color:Color)
	{
		this.width = width;
		this.height = height;
		this.body = body;
		this.color = color;
				
		pivotX = width / 2;
		pivotY = height / 2;

		x = body.x;// - pivotX;
		y = body.y;// - pivotY;
		
		r = body.rotation;
	}
	
}
