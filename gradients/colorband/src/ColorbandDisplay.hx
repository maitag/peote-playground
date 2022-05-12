package;

import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

import peote.view.Element;

// ------------ peote view Element -------------------

class HGradient implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	// size in pixel
	@sizeX public var w:Int=800;
	@sizeY public var h:Int=600;
		
	// colors (RGBA)
	@color public var colorStart:Color = 0x000000ff;
	@color public var colorEnd  :Color = 0xffffffff;
	
	// interpolations from 0.0 (smooth) to 1.0 (linear)
	@custom @varying public var interpolateStart:Float = 0.0;
	@custom @varying public var interpolateEnd  :Float = 0.0;
	
	// this is injected by program of ColorbandDisplay
	public static var fShader =
	"
		vec4 gradient(vec4 c0, vec4 c1, float s0, float s1)
		{
			float x = vTexCoord.x; // horizontally
			
			// semmis interpolation
			float m = mix( 
				mix( smoothstep(0.0     , 1.0 + s1, x), x, s0 ),
				mix( smoothstep(0.0 - s0, 1.0     , x), x, s1 ),
				x 
			);
			
			return mix( c0, c1, m);
		}			
	";

	var DEFAULT_COLOR_FORMULA = "gradient(colorStart, colorEnd, interpolateStart, interpolateEnd)";	
	//var OPTIONS = { alpha:true };

	// interpolation here into API is from 0.0 (linear) to 1.0 (smooth)
	public function new(x:Int, y:Int, w:Int, h:Int, colorStart:Color, colorEnd:Color, interpolateStart:Float, interpolateEnd:Float) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.colorStart = colorStart;
		this.colorEnd = colorEnd;
		this.interpolateStart = 1.0 - Math.max(0.0, Math.min(1.0, interpolateStart));
		this.interpolateEnd = 1.0 - Math.max(0.0, Math.min(1.0, interpolateEnd));
	}
}

// ------------ peote view Display -------------------

class ColorbandDisplay extends Display 
{

	var program:Program;
	var buffer:Buffer<HGradient>;
	
	public function new(x:Int, y:Int, width:Int, height:Int) 
	{
		super(x, y, width, height);
		
		buffer = new Buffer<HGradient>(8, 8, true);
		
		program = new Program(buffer);
		program.injectIntoFragmentShader(HGradient.fShader);
		
		this.addProgram(program);
	}
	
	// TODO: adding another param for scale up to display-size
	public function create(colorband:Colorband, y:Int, height:Int, defaultSize:Int = 32, defaultInterpolate:Interpolate = null )
	{
		if (defaultInterpolate == null) defaultInterpolate = Interpolate.SMOOTH;
		
		var x:Int = 0;
		
		for (i in 0...colorband.length) {
			
			var c = colorband[i];
			
			if (i < colorband.length - 1)
			{				
				var size:Int = (c.size == null) ? defaultSize : c.size;				
				if (size > 0) {
					var interpolate:Interpolate = (c.interpolate == null) ? defaultInterpolate : c.interpolate;
					var interpolateStart:Float = (interpolate.start == null) ? defaultInterpolate.start : interpolate.start;
					var interpolateEnd:Float = (interpolate.start == null) ? defaultInterpolate.start : interpolate.end;
					buffer.addElement( new HGradient(x, y, size, height, c.color, colorband[i+1].color, interpolateStart, interpolateEnd) );
					x += size;
				}
			}
			else { // last into array
				if (c.size != null && c.size > 0)
					buffer.addElement( new HGradient(x, y, c.size, height, c.color, c.color, 0.0, 0.0) );
			}
			
		}
	}
	
	
}