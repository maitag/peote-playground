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
			const float F = 0.0405, K = 0.062, a = 0.2, b = 0.1; // fingerprint
			//const float F = 0.0305, K = 0.062, a = 0.2, b = 0.1; // cellgrow
			//const float F = 0.0305, K = 0.06, a = 0.2, b = 0.1; // mix of both
			//const float F = 0.02, K = 0.055, a = 0.2, b = 0.1; // fluctuation
			//const float F = 0.015, K = 0.055, a = 0.2, b = 0.1; // burnAndDie1
			//const float F = 0.015, K = 0.05, a = 0.2, b = 0.1; // burnAndDie2
			//const float F = 0.0087, K = 0.044, a = 0.2, b = 0.1; // turbulence
			
			const float TIMESTEP = 1.0;
			
			vec4 reactionDiffusion( int textureID )
			{
				vec2 texRes = getTextureResolution(textureID);

				vec2 c = getTextureColor(textureID, vTexCoord).rg;
				
				//vec2 laplacian = 
					  //getTextureColor(textureID, vTexCoord + vec2( 0.0,  1.0) / texRes).rg
					//+ getTextureColor(textureID, vTexCoord + vec2( 1.0,  0.0) / texRes).rg
					//+ getTextureColor(textureID, vTexCoord + vec2( 0.0, -1.0) / texRes).rg
					//+ getTextureColor(textureID, vTexCoord + vec2(-1.0,  0.0) / texRes).rg
					//- 4.0 * c;
					
				// fixing at right and bottom border	
				vec2 laplacian = 
					  getTextureColor(textureID, vec2( vTexCoord.x, min(1.0-1.0/texRes.y, vTexCoord.y + 1.0/texRes.y)) ).rg
					+ getTextureColor(textureID, vec2( min(1.0-1.0/texRes.x, vTexCoord.x + 1.0/texRes.x), vTexCoord.y) ).rg
					+ getTextureColor(textureID, vTexCoord + vec2( 0.0, -1.0) / texRes).rg
					+ getTextureColor(textureID, vTexCoord + vec2(-1.0,  0.0) / texRes).rg
					- 4.0 * c;

				vec2 delta = vec2(
					a * laplacian.r - c.r * c.g * c.g + F * (1.0 - c.r),
					b * laplacian.g + c.r * c.g * c.g - (K + F) * c.g
				);

				
				return vec4(c + delta * TIMESTEP, 0.0, 1.0);
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
