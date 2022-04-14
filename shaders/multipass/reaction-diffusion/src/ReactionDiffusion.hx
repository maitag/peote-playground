package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Texture;

class ReactionDiffusion implements Element
{
	// position in pixel (relative to upper left corner of Display)
	//@posX public var x:Int;
	//@posY public var y:Int;
	
	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	// --------------------------------------------------------------------------
	
	static public function createDisplay(w:Int, h:Int, buffer:Buffer<ReactionDiffusion>, texture:Texture):Display
	{	
		var display = new Display(0, 0, w, h);
		var program = new Program(buffer);
		
		// create a texture-layer named "base"
		program.setTexture(texture, "base", true);

		program.injectIntoFragmentShader(
		"				
			vec4 reactionDiffusion( int textureID )
			{
				
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
				
				
				return vec4(final_colour, 1.0);
			}			
		");
		
		// instead of using normal "base" identifier to get the texture-color
		// the "Texture" postfix is to give access to use getTextureColor() manually 
		// from inside of the injected reactionDiffusion() function to that texture-layer
		
		program.setColorFormula( "reactionDiffusion(base_ID)" );
		
		// this also works if has "base" inside DEFAULT_FORMULA_VARS
		//program.setColorFormula( 'reactionDiffusion(${GaussianBlurHQ.TEXTURE_ID_base})' );
		
		display.addProgram(program);
				
		return display;
	}
	
	
	
	public function new(w:Int, h:Int)
	{
		this.w = w;
		this.h = h;
	}

}
