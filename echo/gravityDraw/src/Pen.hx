package;

import peote.view.Buffer;
import peote.view.Display;
import peote.view.Element;
import peote.view.Color;
import peote.view.Program;

class Pen implements Element implements Entity
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
	
	var DEFAULT_COLOR_FORMULA = "color*circle(radius)";
	var OPTIONS = { alpha:true };

	static var fShader =
	'
		float circle(float radius)
		{
			float x = (vTexCoord.x - 0.5) * 2.0;
			float y = (vTexCoord.y - 0.5) * 2.0;
			float r = sqrt(x * x + y * y);
			float c;
			
			if ( r < 1.0 ) {
				c = 1.0;
			}
			else {
				c = 0.0;
			}
			return c;
		}
	';
	
	static var buffer:Buffer<Pen>;
	static var program:Program;
	
	public static function init(display:Display)
	{
		buffer = new Buffer<Pen>(1024, 1024, true);
		program = new Program(buffer);
		program.injectIntoFragmentShader( fShader );
		program.discardAtAlpha(0.0);
		display.addProgram(program);
	}

	
	public var intersected:Int = 0;
		
	public function new(x:Float, y:Float, radius:Float, color:Color)
	{
		this.x = x;
		this.y = y;
		this.radius = Math.min(10, Math.max(2, radius/6));
		this.color = color;		
		buffer.addElement(this);
	}
	
	public function update(x:Float, y:Float):Void
	{
		setPosition(x, y);
		buffer.updateElement(this);		
	}
	
	
}
