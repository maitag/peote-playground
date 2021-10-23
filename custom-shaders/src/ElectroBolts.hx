package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;

class ElectroBolts implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;
	
	// size in pixel
	@sizeX @varying public var w:Int;
	@sizeY @varying public var h:Int;
	
	@pivotY @const @formula("h/2.0") var py:Float;
	
	@custom("speed") @varying public var speed:Float = 1.0; 
	@custom("absoluteTime") @varying public var absoluteTime:Float = 0.0; 
	@custom("actTime") @varying public var actTime:Float = 0.0; 
	@custom("scale") @varying public var scale:Float = 0.7; 
			
	// color (RGBA)
	// @color public var c:Color = 0xff0000ff;
	
	
	
	static public var buffer:Buffer<ElectroBolts>;
	static public var program:Program;

	
	
	static public function init(display:Display)
	{	
		buffer = new Buffer<ElectroBolts>(1, 1, true);
		program = new Program(buffer);
		
		program.injectIntoFragmentShader(
		"
			float hash( vec2 p, in float s)
			{
				vec3 p2 = vec3(p.xy, 27.0 * abs(sin(s)));
				return fract( sin( dot(p2, vec3(27.1,61.7, 12.4)) )*273758.5453123 );
			}

			float noise( in vec2 p,  in float s)
			{
				vec2 i = floor(p);
				vec2 f = fract(p);
				f *= f * (3.0-2.0*f);

				return mix(mix( hash(i + vec2(0.0, 0.0), s), hash(i + vec2(1.0, 0.0), s), f.x ),
						   mix( hash(i + vec2(0.0, 1.0), s), hash(i + vec2(1.0, 1.0), s), f.x ),
						   f.y) * s;
			}

			float fbm( vec2 p )
			{
				 float v = 0.0;
				 v += noise(p*1.0, 0.35);
				 v += noise(p*2.0, 0.25);
				 v += noise(p*4.0, 0.125);
				 v += noise(p*5.0, 0.0625);
				 return v;
			}

			vec4 electroBolt( vec2 texCoord, vec2 size, float speed, float absoluteTime, float actTime, float scale )
			{
				// change speed
				float t = (actTime-uTime) * speed - absoluteTime;
				
				// TODO: make scaling about the middle !
				// float scale = 0.7;
				
				vec2 uv = vec2( (texCoord.y/scale - 2.0 + scale) * 0.67, texCoord.x * 2.0 * size.x / size.y );
				// from top to down
				//vec2 uv = vec2( (texCoord.x/scale - 2.0 + scale) * 0.67, texCoord.y * 2.0 * size.y / size.x  );
				
				vec3 finalColor = vec3( 0.0 );
				
				for( float i=1.0; i < 4.0; ++i )
				{
					finalColor += vec3( i * 0.075 + 0.1, 0.5, 2.0 ) * abs( 1.0 / ( (uv.x + fbm( uv + t/i ) ) * (i*50.0) ));
				}

				return vec4( finalColor, (finalColor.x + finalColor.y + finalColor.z)/3.0 -0.13*scale  );
			}			
		"
		, true // inject uTime
		);
		
		program.setColorFormula( 'electroBolt(vTexCoord, vSize, speed, absoluteTime, actTime, scale)' );
		program.alphaEnabled = true;
		program.discardAtAlpha(0.0);
		display.addProgram(program);
	}
	
	
	
	public function new(x:Int = 0, y:Int = 0, w:Int = 100, h:Int = 100) 
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		buffer.addElement(this);
	}
	
	public function update() buffer.updateElement(this);

}
