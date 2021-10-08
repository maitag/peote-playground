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
	
	// time fake (until injection not works)
	@custom("fTime") @varying @constStart(0.0) @constEnd(0.000005) @anim("", "constant") var fakedTime:Float;
		
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

			vec4 electroBolt( vec2 texCoord, vec2 size, float time )
			{
				//float time = vPack0; // TODO: how to set an Identifier for fakedTime ?
				
				// original:
				//vec2 uv = ( fragCoord.xy / resolution.xy ) * 2.0 - 1.0;
				//uv.x *= resolution.x / resolution.y;

				// TODO: better transformation into peote-space 
				// (not works same as into the common shadertools!)
				vec2 uv = ( texCoord.xy  ) * 2.0 - 1.0;
				uv.x *= size.x / size.y;
				

				vec3 finalColor = vec3( 0.0 );
				
				for( float i=1.0; i < 2.0; ++i )
				{
					float t = abs( 1.0 / ( (uv.x + fbm( uv + time/i ) ) * (i*50.0) )) ;
					finalColor +=  t * vec3( i * 0.075 + 0.1, 0.5, 2.0 );
				}

				return vec4( finalColor, 1.0 );
			}			
		");
		
		program.setColorFormula( 'electroBolt(vTexCoord, vSize, fTime)' );
		
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

}
