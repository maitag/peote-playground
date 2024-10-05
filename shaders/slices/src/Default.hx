package;

import peote.view.*;

class Default implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;
	
	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;

	@texSlot public var slot:Int = 0;

	// --------------------------------------------------------------------------
	
	static public var buffer:Buffer<Default>;
	static public var program:Program;
	
	static public function init(display:Display, texture:Texture)
	{	
		buffer = new Buffer<Default>(1, 1024, true);
		program = new Program(buffer);
		
		// creates a texture-layer named "base"
		program.setTexture(texture, "base", true );

		program.injectIntoFragmentShader(
		"			
			vec4 slice( int textureID )
			{				
				vec4 col = vec4(0.0);
				
				// vec2 texRes = getTextureResolution( textureID );				
				
				// vTexCoord vec2 goes allways from 0.0 to 1.0 (in x and y):

				col = getTextureColor( textureID, vTexCoord );
				
				return col;
			}			
		");
		
		// instead of using normal "base" identifier to fetch the texture-color,
		// the postfix "_ID" gives access to use getTextureColor(textureID, ...) or getTextureResolution(textureID)		
		program.setColorFormula( "slice(base_ID)" );
				
		display.addProgram(program);
	}
	
	public function new(x:Int, y:Int, w:Int, h:Int) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		buffer.addElement(this);
	}

}
