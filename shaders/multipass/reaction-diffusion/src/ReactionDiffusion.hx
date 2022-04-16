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
			const float F = 0.0545, K = 0.059, a = 0.2, b = 0.1;

			const float TIMESTEP = 1.0;
			
			vec4 reactionDiffusion( int textureID )
			{
				vec2 texRes = getTextureResolution(textureID);

				vec2 val = getTextureColor(textureID, vTexCoord).rg;
				
				vec2 laplacian = 
					  getTextureColor(textureID, vTexCoord + vec2( 0.0,  1.0) / texRes).rg
					+ getTextureColor(textureID, vTexCoord + vec2( 1.0,  0.0) / texRes).rg
					+ getTextureColor(textureID, vTexCoord + vec2( 0.0, -1.0) / texRes).rg
					+ getTextureColor(textureID, vTexCoord + vec2(-1.0,  0.0) / texRes).rg
					- 4.0 * val;

				vec2 delta = vec2(
					a * laplacian.x - val.x * val.y * val.y + F * (1.0 - val.x),
					b * laplacian.y + val.x * val.y * val.y - (K + F) * val.y
				);

				
				return vec4(val + delta * TIMESTEP, 0, 1.0);
			}			
		");
		
		// instead of using normal "base" identifier to get the texture-color
		// the "Texture" postfix is to give access to use getTextureColor() manually 
		// from inside of the injected reactionDiffusion() function to that texture-layer
		
		program.setColorFormula( "reactionDiffusion(base_ID)" );
		
		// this also works if has "base" inside DEFAULT_FORMULA_VARS
		//program.setColorFormula( 'reactionDiffusion(${GaussianBlurHQ.TEXTURE_ID_base})' );
		
		program.alphaEnabled = false;
		display.addProgram(program);
				
		return display;
	}
	
	
	
	public function new(w:Int, h:Int)
	{
		this.w = w;
		this.h = h;
	}

}
