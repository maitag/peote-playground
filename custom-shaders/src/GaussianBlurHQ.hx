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
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	@texUnit("base") public var unit:Int;
	
	// --------------------------------------------------------------------------
	
	static public var buffer:Buffer<GaussianBlurHQ>;
	static public var program:Program;
	
	static public function init(display:Display, texture:Texture)
	{	
		buffer = new Buffer<GaussianBlurHQ>(1, 1, true);
		program = new Program(buffer);
		
		// create a texture-layer named "base"
		program.setTexture(texture, "base", true);

		program.injectIntoFragmentShader(
		"				
			float normpdf(in float x, in float sigma) { return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma; }
			
			vec4 blur( int textureID )
			{
				const int mSize = 11;
				
				const int kSize = (mSize-1)/2;
				float kernel[mSize];
				
				float sigma = 7.0;
				float Z = 0.0;
				
				for (int j = 0; j <= kSize; ++j) kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
				for (int j = 0; j <  mSize; ++j) Z += kernel[j];
				
				vec3 final_colour = vec3(0.0);
				
				for (int i = -kSize; i <= kSize; ++i)
				{
					for (int j = -kSize; j <= kSize; ++j)
					{
						final_colour += kernel[kSize+j] * kernel[kSize+i] *
							getTextureColor(  textureID, vTexCoord + vec2(float(i), float(j)) / getTextureResolution(textureID)  ).rgb;
					}
				}
				
				return vec4(final_colour / (Z * Z), 1.0);
			}			
		");
		
		// instead of using normal "base" identifier to get the texture-color
		// the "Texture" postfix is to give access to use getTextureColor() manually 
		// from inside of the injected blur() function to that texture-layer
		program.setColorFormula( "blur(baseTexture)" );
		
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
