package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Texture;

//equations taken from Comstock, William S., "Pattern formation in a model of an oscillatory Belousov-Zhabotinsky medium" (1992). Graduate Student Theses, Dissertations, & Professional Papers 
//https://scholarworks.umt.edu/etd/8370?utm_source=scholarworks.umt.edu%2Fetd%2F8370&utm_medium=PDF&utm_campaign=PDFCoverPages


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
			//const float dr=0.00001, dg=0.00001, db=0.000035, s=1., c=2., w=1., f=0.63, q=0.4;
			//const float dr=0.0004, dg=0.0005, db=0.00045, s=0.1098, c=0.2, w=0.1, f=0.5, q=0.1; // test02
			//const float dr=0.0004, dg=0.0005, db=0.00045, s=0.1098, c=0.176, w=1.0, f=0.5, q=0.1; // test03
			//const float dr=0.0004, dg=0.0005, db=0.00045, s=0.1098, c=0.176, w=1.0, f=0.5, q=0.099; // test04 (stars)
			const float dr=0.0004, dg=0.0005, db=0.00045, s=0.1098, c=0.076, w=1.0, f=0.5, q=0.01; // test05
			
			//const float TIMESTEP = 1.0;
			const float TIMESTEP = 0.1;
			
			vec4 reactionDiffusion( int textureID )
			{
				vec2 texRes = getTextureResolution(textureID);

				vec3 col = getTextureColor(textureID, vTexCoord).rgb;

				
				//vec2 laplacian = 
					  //getTextureColor(textureID, vTexCoord + vec2( 0.0,  1.0) / texRes).rg
					//+ getTextureColor(textureID, vTexCoord + vec2( 1.0,  0.0) / texRes).rg
					//+ getTextureColor(textureID, vTexCoord + vec2( 0.0, -1.0) / texRes).rg
					//+ getTextureColor(textureID, vTexCoord + vec2(-1.0,  0.0) / texRes).rg
					//- 4.0 * c;
					
				// fixing at right and bottom border	
				vec3 laplacian = 
					  getTextureColor(textureID, vec2( vTexCoord.x, min(1.0-1.0/texRes.y, vTexCoord.y + 1.0/texRes.y)) ).rgb
					+ getTextureColor(textureID, vec2( min(1.0-1.0/texRes.x, vTexCoord.x + 1.0/texRes.x), vTexCoord.y) ).rgb
					+ getTextureColor(textureID, vTexCoord + vec2( 0.0, -1.0) / texRes).rgb
					+ getTextureColor(textureID, vTexCoord + vec2(-1.0,  0.0) / texRes).rgb
					- 4.0 * col;


				vec3 delta = vec3(
					dr * laplacian.r + s * (col.g - col.r * col.g + col.r * (1.0 - col.b / c) - q * col.r * col.r),
					dg * laplacian.g + 1.0/s * (-col.g - col.r * col.g + f*col.b),
					db * laplacian.b + w * (col.r * (1.0 - col.b / c) - col.b)
				);

				
				return vec4(col + delta * TIMESTEP, 1.0);
			}			
		");
		
		// instead of using normal "base" identifier to get the texture-color
		// the "_ID" postfix is to give access to use getTextureColor() manually 
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
