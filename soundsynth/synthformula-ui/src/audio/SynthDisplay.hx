package audio;

import haxe.io.Float32Array;

import peote.view.PeoteView;
import peote.view.intern.Util;
import peote.view.Element;
import peote.view.Display;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.Program;
import peote.view.Buffer;

class SynthElement implements Element
{
	// position allways top-left
	@posX @const public var x:Int = 0;
	@posY @const public var y:Int = 0;
	
	// size
	@sizeX public var size:Int;
	@sizeY @const @formula("size") var _h:Int;
			
	public function new(size:Int)
	{
		this.size = size;
	}

}

class SynthDisplay extends Display
{	
	public var buffer:Buffer<SynthElement>;
	public var program:Program;

	var size:Int;
	
	public function new(peoteView:PeoteView, sampleRate:Int, formula:Formula, duration:Float)
	{	
		// TODO: use also the not-rounded to cut off in shader at the correct samplerate and duration
		// cos of round-up here: 
		size = Std.int( Math.ceil(Math.sqrt(sampleRate * duration / 4)) );
		
		super(0, 0, size, size);

		// create framebuffer texture to render into
		var texture = new Texture(size, size, 1, { format: TextureFormat.FLOAT_RGBA });
		setFramebuffer(texture, peoteView);	

		buffer = new Buffer<SynthElement>(1, 1, true);
		program = new Program(buffer);
		
		program.autoUpdate = false;
		program.blendEnabled = false;
		program.discardAtAlpha(null);
		
		program.setColorFormula( 'synth(vTexCoord)');

		// updateShader(sampleRate, formula, duration);
		
		addProgram(program);

		var element = new SynthElement(size);
		buffer.addElement(element);

		updateSynthData(sampleRate, formula, duration);
	}


	public function updateSynthData(sampleRate:Int, formula:Formula, duration:Float)
	{
		updateShader(sampleRate, formula, duration);
		
		// render into texture
		peoteView.renderToTexture(this);
	}


	public function getSynthData():Float32Array
	{
		return fbTexture.readPixelsFloat32(0, 0, size, size);
	}  


	public function updateShader(sampleRate:Int, formula:Formula, duration:Float)
	{
		trace("new shader formula:", formula.toString("glsl"));
		
		program.injectIntoFragmentShader(
			'
			// #define SRATE ${Util.toFloatString(sampleRate)}
			// #define DURATION ${Util.toFloatString(duration)}

			#define PI 3.1415926538
			
			float getValue( float x)
			{
				// todo: cut off if size is greater as expected for the duration and samplerate
				return ${formula.toString("glsl")};
			}
			
			vec4 synth( vec2 texCoord)
			{				                            // TODO: duration!!! -> cut off
				float pos = texCoord.y * ${Util.toFloatString(4*size*size/sampleRate)} + 
					texCoord.x * ${Util.toFloatString(4*size/sampleRate)};
				
				return vec4(
					getValue(pos ),
					getValue(pos + 1.0 ),
					getValue(pos + 2.0 ),
					getValue(pos + 3.0 )
				);
			}			
			',
			false,
			null, // TODO: uniforms for formula parameters
			true // force a program update
		);	
	}
	
}
