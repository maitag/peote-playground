package;

import peote.view.*;

class GaussianBlurHQ implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;
	
	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	// TODO:
	//var DEFAULT_FRAGMENT_SHADER = "";	
	//var DEFAULT_COLOR_FORMULA = "blur(base_ID)";
	
	//var DEFAULT_FORMULA_VARS = ["base"  => 0xff0000ff];
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
				
				//vec2 texRes = getTextureResolution(textureID);
				//for (int i = -kSize; i <= kSize; ++i)
				//{
					//for (int j = -kSize; j <= kSize; ++j)
					//{
						//final_colour += kernel[kSize+j] * kernel[kSize+i] *
							//getTextureColor( textureID, vTexCoord + vec2(float(i), float(j)) / texRes ).rgb;
					//}
				//}
				
				// fix if kernel-offset is over the border
				vec2 texRes = getTextureResolution(textureID);
				vec2 texResSize = texRes + vec2(float(kSize+kSize),float(kSize+kSize));			
				for (int i = 0; i <= kSize+kSize; ++i)
				{
					for (int j = 0; j <= kSize+kSize; ++j)
					{
						final_colour += kernel[j] * kernel[i] *
							getTextureColor( textureID, (vTexCoord*texRes + vec2(float(i),float(j))) / texResSize ).rgb;
					}
				}
				
				return vec4(final_colour / (Z * Z), 1.0);
			}			
		");
		
		// instead of using normal "base" identifier to get the texture-color
		// the "_ID" postfix is to give access to use getTextureColor() manually 
		// from inside of the glsl blur() function to that texture-layer
		
		program.setColorFormula( "blur(base_ID)" );
		
		// this also works if has "base" inside DEFAULT_FORMULA_VARS
		//program.setColorFormula( 'blur(${GaussianBlurHQ.TEXTURE_ID_base})' );
		
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
