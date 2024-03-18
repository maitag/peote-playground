package;

import peote.view.*;

class UVmap implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;
	
	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	//let the texture shift/resize inside slot/texCoords/tile area of Element
	//@texPosX("image")public var txOffset:Int = 3000;
	@texPosX("image") @constStart(3050) @constEnd(3000) @anim("offset", "constant") public var txOffset:Int;
	@texPosY("image") public var tyOffset:Int = 0;
	//@texSizeX("image") public var twOffset:Int = 5000;
	@texSizeY("image") public var thOffset:Int = 24;
	
	var OPTIONS = { texRepeatX:true, texRepeatY:false, blend:true };
	
	// TODO:
	//var DEFAULT_FRAGMENT_SHADER = "";	
	
	//var DEFAULT_COLOR_FORMULA = "'uvmapping(${UVmap.TEXTURE_uvmap}.rgb, ${UVmap.TEXTURE_ID_image})'";
	
	//var DEFAULT_FORMULA_VARS = ["uvmap"  => 0x00ff00ff];
	//var DEFAULT_FORMULA_VARS = ["image"  => 0xff0000ff];
	// --------------------------------------------------------------------------
	
	static public var buffer:Buffer<UVmap>;
	static public var program:Program;
	
	static public function init(display:Display, uvTexture:Texture, imageTexture:Texture)
	{	
		buffer = new Buffer<UVmap>(1, 1, true);
		program = new Program(buffer);
		
		// create named texture-layer
		program.setTexture(uvTexture, "uvmap"); // holds the upmap
		program.setTexture(imageTexture, "image", true); // holds the image that need to transformate via uvmap

		program.injectIntoFragmentShader(
		"				
			vec4 uvmapping( vec3 uvRGB, int imgTexID )
			{		
				
				// using red + blue colorchannels for horizontal mapping
				//float highByte = uvRGB.r * (256.0 / 257.0);
				//float lowByte  = uvRGB.b * (1.0 / 257.0);				
				//float uCoord = highByte + lowByte;
				
				float uCoord =  (uvRGB.r * 256.0 + uvRGB.b ) / 257.0;
				
				// using green colorchannel for vertically mapping
				float vCoord = uvRGB.g;

				//vec2 imgTexRes = getTextureResolution(imgTexID);
				
				return getTextureColor( imgTexID, vec2( uCoord, vCoord ) );
				//return getTextureColor( imgTexID, vec2( clamp(uCoord*1.0, 0.0, 1.0), clamp(vCoord*1.0, 0.0, 1.0) ) );
				
				//return vec4(uvRGB, 1.0); // to shows the pure uvmap uncomment here!
			}			
		");
		
		// instead of using normal "image" identifier to get the texture-color,
		// the "_ID" postfix is to give access to use getTextureColor() manually 
		// from inside of the glsl uvmapping() function for that texture-layer
		
		program.setColorFormula( "uvmapping(uvmap.rgb, image_ID)" );
				
		//program.setFragmentFloatPrecision("high", true);
		
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
