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
	@custom @varying public var smoothStart:Float = 0.0;
	@custom @varying public var smoothEnd  :Float = 0.0;
	
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

	var DEFAULT_COLOR_FORMULA = "gradient(colorStart, colorEnd, smoothStart, smoothEnd)";
	
	//var OPTIONS = { alpha:true };

	public function new() {}
}
