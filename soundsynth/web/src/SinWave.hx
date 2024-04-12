package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;

class SinWave implements Element
{
	// position allways top-left
	@posX @const public var x:Int = 0;
	@posY @const public var y:Int = 0;
	
	// texture w * h -> samplerate
	@sizeX @varying public var w:Int;
	@sizeY @varying public var h:Int;
		
	// frequence
	@custom("freq") @varying public var freq:Float;

	
	// --------------------------------------------------------------------------	
	
	static public var buffer:Buffer<SinWave>;
	static public var program:Program;	
	
	static public function init(display:Display, useFloat:Bool = false)
	{	
		buffer = new Buffer<SinWave>(1, 1, true);
		program = new Program(buffer);
		
		program.injectIntoFragmentShader(
		'
			#define PI 3.1415926538
			
			float getValue( float pos, float srate, float freq)
			{
				${ (useFloat) ? 
					"return   sin( (pos * PI * 2.0 * freq) / srate );" :
					"return ( sin( (pos * PI * 2.0 * freq) / srate ) + 1.0) / 2.0;"
				}
				
			}
			
			vec4 sinwave( vec2 texCoord, vec2 size, float freq )
			{
				
				float pos = 4.0 * (texCoord.y * size.x * size.y + texCoord.x * size.x);
				float srate = 4.0 * size.x * size.y;
				
				float r = getValue(pos,   srate, freq );
				float g = getValue(pos+1.0, srate, freq );
				float b = getValue(pos+2.0, srate, freq );
				float a = getValue(pos+3.0, srate, freq );

				return vec4( r, g, b, a );
			}			
		'
		);
		
		program.setColorFormula( 'sinwave(vTexCoord, vSize, freq)' );
		
		program.blendEnabled = false;
		program.discardAtAlpha(null);
		display.addProgram(program);
	}
	
	
	
	public function new(freq:Int, w:Int, h:Int)
	{
		this.freq = freq;
		this.w = w;
		this.h = h;
		buffer.addElement(this);
	}
	
	public function update() buffer.updateElement(this);

}
