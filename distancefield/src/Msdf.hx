package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Texture;

class Msdf implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;
	
	@color public var color:Color = 0xff0000ff;
	@color public var bgColor:Color = 0x000000ff;
	
	// size in pixel
	@sizeX @varying public var w:Int;
	@sizeY @varying public var h:Int;
	
	// --------------------------------------------------------------------------
	
	static public var buffer:Buffer<Msdf>;
	static public var program:Program;
	
	static public function init(display:Display, texture:Texture)
	{	
		buffer = new Buffer<Msdf>(1, 1, true);
		program = new Program(buffer);
		
		// create a texture-layer named "base"
		program.setTexture(texture, "base", true);

		program.injectIntoFragmentShader(
		"				
			
			float median(float r, float g, float b) {
				return max(min(r, g), min(max(r, g), b));
			}
		
			float screenPxRange( vec2 texCoord, vec2 size ) {
				//vec2 unitRange = vec2(2.0)/size;
				vec2 unitRange = vec2(2.0)/vec2(textureSize(uTexture0, 0));
				vec2 screenTexSize = vec2(1.0)/fwidth(texCoord);
				return max(0.5*dot(unitRange, screenTexSize), 1.0);
			}
			
			float msdf( vec4 tex, vec2 texCoord, vec2 size )
			{				
				float sd = median(tex.r, tex.g, tex.b);
				float screenPxDistance = screenPxRange(texCoord, size)*(sd - 0.5);
				
				return clamp(screenPxDistance + 0.5, 0.0, 1.0);
			}			
		");
		
		// instead of using normal "base" identifier to get the texture-color
		// the "Texture" postfix is to give access to use getTextureColor() manually 
		// from inside of the injected blur() function to that texture-layer
		
		//program.setColorFormula( "msdf(base_ID)" );
		program.setColorFormula("mix(bgColor, color, msdf(base, vTexCoord, vSize))");
		program.alphaEnabled = false;
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
