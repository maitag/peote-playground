package;

import peote.view.Element;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Display;
import peote.view.Color;

class Water2D implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;
	
	// size in pixel
	// varying is need to use vSize in fragmentshader
	// @sizeX @varying public var w:Int;
	// @sizeY @varying public var h:Int;
	@sizeX public var w:Int;
	@sizeY public var h:Int;

	// color (RGBA)
	@color @varying public var color:Color = 0x1948B2FF;
	
	// --------------------------------------------------------------------------	
	
	static public var buffer:Buffer<Water2D>;
	static public var program:Program;	
	
	static public function init(display:Display)
	{	
		buffer = new Buffer<Water2D>(1, 1, true);
		program = new Program(buffer);
		
		program.injectIntoFragmentShader(
		"
			uniform vec2 uZoom; // this is need if using gl_FragCoord to make a global pattern (but keep into zoom of the Display)

			const float param_A = 0.87, param_B = 0.2223, param_C = -0.1843, param_D = 0.9126, param_E = 1.2;
			const float param_INTERFERENCE = 0.3, param_INTERFERENCE_ZOOM = 1.8, param_INTERFERENCE_SHIFT = 0.14;
			const float param_SPEED = 0.03, param_ASPECT = 0.4, param_ZOOM = 1.0;
			const float param_CONTRAST = 0.25;

			vec2 sin2(vec2 p) {
				return abs(vec2(sin(p.x + sin(p.y)), sin(p.y + sin(p.x))));
			}
			
			
			float sineWaves(vec2 p1)
			{
				vec2 p2 = p1;
				float ret = 0.0;
				mat2 matrix = param_E * mat2(param_A, param_B, param_C, param_D);
				float t = uTime * param_SPEED;
				
				for (int i=0; i<5; i++)
				{
					p1 = (p1 + ( sin2(2.0*p2) * param_INTERFERENCE + t) ) * matrix;
					p2 = p2 * param_INTERFERENCE_ZOOM + param_INTERFERENCE_SHIFT;
					ret += abs( fract( p1.y + abs(fract(p1.x) - 0.5) ) - 0.5);
				}
				
				return param_CONTRAST / ret;
			}
			

			vec4 water2D( vec4 c )
			{
				// float waves = sineWaves( vec2(vTexCoord.x * vSize.x, (vTexCoord.y * vSize.y) / param_ASPECT) / (60.0 * param_ZOOM) );
				float waves = sineWaves( vec2(gl_FragCoord.x / uZoom.x, (gl_FragCoord.y / uZoom.y) / param_ASPECT) / (60.0 * param_ZOOM) );
				
				waves *= waves;
				return vec4( waves + vec3(c.r, c.g, c.b), c.a);
			}			
		"
		, true // inject uTime
		);
		
		program.setColorFormula( 'water2D(color)' );
		program.blendEnabled = true;
		program.discardAtAlpha(0.0);
		display.addProgram(program);
	}
	
	
	
	public function new(x:Int = 0, y:Int = 0, w:Int = 100, h:Int = 100, color:Color) 
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.color = color;
		buffer.addElement(this);
	}
	
	public function update() buffer.updateElement(this);

}
