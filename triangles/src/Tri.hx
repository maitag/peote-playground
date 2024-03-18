package;

import peote.view.*;

class Tri implements Element
{
	@color public var c0:Color = 0xff0000ff;
	@color public var c1:Color = 0x00ff00ff;
	@color public var c2:Color = 0x0000ffff;
	
	@custom public var tip:Float = 0.5; // upper corner
	
	@posX @formula("x0 + (aSize.x - w)*((2.0*tip-1.0)* 0.0 +tip) ") public var x0:Float;
	@posY public var y0:Float;
	
	public var x1:Float;
	public var y1:Float;
	
	public var x2:Float;
	public var y2:Float;
	
	
	// calculated size in pixel
	@sizeX @formula("(1.0-aPosition.y) * w") var w:Float;
	@sizeY var h:Float = 100.0;
	
	
	// calculated rotation around (x0, y0)
	@rotation var r:Float = 0.0;

	// z-index
	@zIndex public var z:Int = 0;
	
	
	
	
	// ---------------------------------
	
	static public var buffer:Buffer<Tri>;
	static public var program:Program;

	
	// -----------------------------------------------
	
	
	static public function init(display:Display, bufferStartSize:Int=4096, bufferGrowBy:Int=4096, bufferAutoShrink:Bool = true)
	{	
		buffer = new Buffer<Tri>(bufferStartSize, bufferGrowBy, bufferAutoShrink);
		program = new Program(buffer);
		
		program.injectIntoFragmentShader(
		"
			vec4 triangleColor( vec2 texCoord ) {
				float y = vTexCoord.y;
				float w1 =  vTexCoord.x;
				float w2 = 1.0 - y - w1;
				return vColor2*y + vColor1*w1 + vColor0*w2;
				//return vColor0*(1.0 - vTexCoord.y) + vColor1*(1.0 - vTexCoord.x) + vColor2*(vTexCoord.y - 1.0 + vTexCoord.x);
			}			
		");

		program.setColorFormula( 'triangleColor(vTexCoord)' );

		display.addProgram(program);
	}
	
	
	
	public function new(
		x0:Float, y0:Float, c0:Color,
		x1:Float, y1:Float, c1:Color,
		x2:Float, y2:Float, c2:Color
	)
	{
		this.x0 = x0; this.y0 = y0; this.c0 = c0;
		this.x1 = x1; this.y1 = y1; this.c1 = c1;
		this.x2 = x2; this.y2 = y2; this.c2 = c2;
		
		_update();
		buffer.addElement(this);
	}

	public function update()
	{		
		_update();
		buffer.updateElement(this);
	}
	
	inline function _update()
	{		
		var a:Float = x0 - x1;
		var b:Float = y0 - y1;			
		w = Math.sqrt( a * a + b * b );
			
		r = Math.atan2(x1 - x0, - (y1 - y0) )*(180 / Math.PI) - 90;
		
		h = ( x0*(y1-y2) + x1*(y2-y0) + x2*(y0-y1) ) / w;

		// calculating the "tip" (how much the triangle is tend inside quad)
		a = x0 - x2;
		b = y0 - y2;
		var c:Float =  Math.sqrt( a * a + b * b );
		
		// problem for left tending
		tip = Math.sqrt( c * c - h * h ) / w;
		
	}
	
}
