package;

import peote.view.Element;
import peote.view.Color;

import echo.Body;

class Circle implements Element implements XYR_Interface
{
	@posX @set("Position") public var x:Float = 0.0;
	@posY @set("Position") public var y:Float = 0.0;
		
	@rotation public var r:Float = 0.0;
	
	@custom @varying public var radius:Float = 50.0;
	
	// size calculation by radius
	@sizeX @const @formula("radius * 2.0") var width:Float;
	@sizeY @const @formula("radius * 2.0") var height:Float;
	
	// pivot calculation by radius
	@pivotX @const @formula("radius") var px:Float;
	@pivotY @const @formula("radius") var py:Float;
	
	@color public var color:Color = 0x000000ff;
	
	// z-index
	// @zIndex public var z:Int = 0;	
	
	
	// -------------------------------------------------------
	public var body:Body; // <- bridge to the echo-physic body
	
	public function new(body:Body, radius:Float, color:Color)
	{
		this.radius = radius;
		this.body = body;
		this.color = color;
		
		x = body.x;// - pivotX;
		y = body.y;// - pivotY;
		
		if (body.rotation != null) r = body.rotation;
	}
	
}
