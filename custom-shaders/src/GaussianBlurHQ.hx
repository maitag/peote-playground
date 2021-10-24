package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Texture;

class GaussianBlurHQ implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;
	
	// size in pixel
	@sizeX @varying public var w:Int;
	@sizeY @varying public var h:Int;
	
	@unit("texture") public var unit:Int;
	
	// --------------------------------------------------------------------------
	
	static public var buffer:Buffer<GaussianBlurHQ>;
	static public var program:Program;
	
	static public function init(display:Display, texture:Texture)
	{	
		buffer = new Buffer<GaussianBlurHQ>(1, 1, true);
		program = new Program(buffer);
		
		program.setTexture(texture, "texture", false);

		program.injectIntoFragmentShader(
		"
			float normpdf(in float x, in float sigma)
			{
				return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
			}
			
			vec4 blur( vec4 texData, vec2 size )
			{
				const int mSize = 11;
				const int kSize = (mSize-1)/2;
				float kernel[mSize];
				vec3 final_colour = vec3(0.0);
				
				float sigma = 7.0;
				float Z = 0.0;
				for (int j = 0; j <= kSize; ++j) kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
				for (int j = 0; j <  mSize; ++j) Z += kernel[j];
				
				for (int i = -kSize; i <= kSize; ++i)
				{
					for (int j = -kSize; j <= kSize; ++j)
					{
						final_colour += kernel[kSize+j] * kernel[kSize+i] *
						texture(uTexture0, (vTexCoord.xy + vec2(float(i),float(j))/vSize ) * vec2(0.78125, 0.5859375) ).rgb;
					}
				}
				return vec4(final_colour / (Z * Z), 1.0);
				
				// TODO: needs better coordinate-transforming here for gl_FragCoord-usage
				//return vec4( texture(uTexture0, vec2((gl_FragCoord.x-200.0)*0.78125/vSize.x, vTexCoord.y *  0.5859375) ) );
				//return texData;
			}			
		");
		
		program.setColorFormula( 'blur(texture, vSize)' );
		//program.alphaEnabled = true;
		//program.discardAtAlpha(0.0);
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
