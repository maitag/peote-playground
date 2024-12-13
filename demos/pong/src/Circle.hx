package;

import peote.view.*;

class Circle implements Element
{
	@posX @set("Position") public var x:Float = 0.0;
	@posY @set("Position") public var y:Float = 0.0;
	
	@custom @varying public var radius:Float = 50.0;
	
	// size calculation by radius
	@sizeX @const @formula("radius * 2.0") var w:Float;
	@sizeY @const @formula("radius * 2.0") var h:Float;
	
	// pivot calculation by radius
	@pivotX @const @formula("radius") var px:Float;
	@pivotY @const @formula("radius") var py:Float;
	
	// color (RGBA)
	@color public var color:Color = 0x000000ff;
	
	var DEFAULT_COLOR_FORMULA = "vec4(1, 0.1 + sin(uTime*2.0), 0.4 + cos(uTime*5.0), 1)*circle(radius)";
	var OPTIONS = { blend: true };

    public var vx:Float = 100; 
	public var vy:Float = 100;

	static var fShader =
	'
		float circle(float radius)
		{
			float x = (vTexCoord.x - 0.5) * 2.0;
			float y = (vTexCoord.y - 0.5) * 2.0;
			float r = sqrt(x * x + y * y);
			float c;
			
			if ( r <= 1.0) {
				c = 1.0;
			}
			else {
				c = 0.0;
			}
			return c;
		}
	';
	
	static var buffer:Buffer<Circle>;
	static var program:Program;
	
	public static function init(display:Display)
	{
		buffer = new Buffer<Circle>(1024, 1024, true);
		program = new Program(buffer);
		program.injectIntoFragmentShader(fShader, true);
		program.discardAtAlpha(0.0);
		display.addProgram(program);
	}

	
	public var intersected:Int = 0;
		
	public function new(x:Float, y:Float, radius:Float, color:Color)
	{
		this.x = x;
		this.y = y;
		this.radius = radius;
		this.color = color;		
		buffer.addElement(this);
	}
	
	public function update(dt:Float):Void
	{
        this.y -= this.vy * (dt/1000);
        this.x += this.vx * (dt/1000);

        buffer.updateElement(this);		
	}
	
	
}