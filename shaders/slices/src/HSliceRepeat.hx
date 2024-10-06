package;

import peote.view.*;

class HSliceRepeat implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;
	
	// size in pixel
	@varying @sizeX public var w:Int;
	@varying @sizeY public var h:Int;

	// at what x position it have to slice (width of the arrow-head in texturedata pixels)
	@varying @custom public var sliceX:Int = 50;

	@texSlot public var slot:Int = 0;

	// --------------------------------------------------------------------------
	
	static public var buffer:Buffer<HSliceRepeat>;
	static public var program:Program;
	
	static public function init(display:Display, texture:Texture)
	{	
		buffer = new Buffer<HSliceRepeat>(1, 1024, true);
		program = new Program(buffer);
		
		// creates a texture-layer named "base"
		program.setTexture(texture, "base", true );
		
		program.injectIntoFragmentShader(
		'		
			vec4 slice( int textureID, float sliceX )
			{				
				float slicePositionX = 1.0 - (sliceX/${texture.slotHeight}.0 * vSize.y) / vSize.x;
				
				float x = vTexCoord.x;

				if (x < slicePositionX)
				{
					// repeats the body of the arrow (like an accordion at now ;)

					// float a = (${texture.slotWidth}.0 - sliceX) / ${texture.slotHeight}.0 * vSize.y;
					// float b = x / slicePositionX;
					// float c = (sliceX/${texture.slotHeight}.0) * vSize.y;					
					// x = mix(0.0, 1.0 - sliceX/${texture.slotWidth}.0, mod( b * ( ( vSize.x - c  )/a )  , slicePositionX )  ); // accordion
					// x = mix(0.0, 1.0 - sliceX/${texture.slotWidth}.0, mod( b * ( ( vSize.x - c  )/a )  , 1.0 )  );

					// math term is long and unoptimized here:
					// x = mix(0.0, 1.0 - sliceX/${texture.slotWidth}.0, mod(x/slicePositionX * (vSize.x - sliceX/${texture.slotHeight}.0 * vSize.y)/(${texture.slotWidth}.0 - sliceX)/${texture.slotHeight}.0 * vSize.y, 1.0 )  );
					
					// optimized:

					x = mix(0.0, 1.0 - sliceX/${texture.slotWidth}.0, mod(x/slicePositionX * 
					// repeat from the other side:
					// x = mix(1.0 - sliceX/${texture.slotWidth}.0, 0.0, mod((1.0-x/slicePositionX) * 
					
					// reducing the math-term in 3 steps:
					// (vSize.x - sliceX/${texture.slotHeight}.0 * vSize.y)/ (${texture.slotWidth}.0 - sliceX)/${texture.slotHeight}.0 * vSize.y
					// (vSize.x/vSize.y * ${texture.slotHeight}.0/sliceX - 1.0) / (${texture.slotWidth}.0/sliceX - 1.0)
					   (vSize.x/vSize.y * ${texture.slotHeight}.0 - sliceX) / (${texture.slotWidth}.0 - sliceX)

					, 1.0 ));

				}
				else
				{
					// keeps head of the arrow into aspect ratio
					x = mix(1.0 - sliceX/${texture.slotWidth}.0, 1.0, (x - slicePositionX) / (1.0 - slicePositionX) );
				}

				return getTextureColor( textureID, vec2 (x, vTexCoord.y) );
			}			
		');
		
		// instead of using normal "base" identifier to fetch the texture-color,
		// the postfix "_ID" gives access to use getTextureColor(textureID, ...) or getTextureResolution(textureID)		
		program.setColorFormula( "slice(base_ID, sliceX)" );
				
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
