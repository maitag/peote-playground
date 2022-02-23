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
	
	// size in pixel
	@custom("size") @varying public var size:Float;
	
	// frequence
	@custom("freq") @varying public var freq:Float;

	// texture is allways square
	@sizeX @const @formula("size") public var w:Float;
	@sizeY @const @formula("size") public var h:Float;
	
	
	// --------------------------------------------------------------------------	
	
	static public var buffer:Buffer<SinWave>;
	static public var program:Program;	
	
	static public function init(display:Display)
	{	
		buffer = new Buffer<SinWave>(1, 1, true);
		program = new Program(buffer);
		
		program.injectIntoFragmentShader(
		"
			#define PI 3.1415926538
			
			float getValue( float pos, float srate, float freq)
			{
				return sin( (pos * PI * 2.0 * freq) / srate);
			}
			
			vec4 sinwave( vec2 texCoord, float size, float freq )
			{
				
				float pos = 4.0 * (texCoord.y * size * size + texCoord.x * size);
				
				float srate = size * size;
				
				float r = getValue(pos,   srate, freq );
				float g = getValue(pos+1, srate, freq );
				float b = getValue(pos+2, srate, freq );
				float a = getValue(pos+3, srate, freq );

				return vec4( r, g, b, a );
			}			
		"
		);
		
		program.setColorFormula( 'sinwave(vTexCoord, size, freq)' );
		//program.alphaEnabled = true;
		//program.discardAtAlpha(0.0);
		display.addProgram(program);
	}
	
	
	
	public function new(freq:Int, srate:Int)
	{
		this.freq = freq;
		size = Math.sqrt(srate);
		buffer.addElement(this);
	}
	
	public function update() buffer.updateElement(this);

}
