package;

import peote.view.Element;
import peote.view.Color;

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
