package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Texture;
import peote.view.utils.BlendFactor;

class DepthPerPixel implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@varying @posX public var x:Int ;
	@varying @posY public var y:Int;
	
	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	@texTile public var tile:Int;
	
	@varying @custom public var depth:Float = 0.0;
	
	@pivotX @const @formula("w * 0.5") var px:Int;
	@pivotY @const @formula("h * 0.5") var py:Int;
	
	// --------------------------------------------------------------------------
	
	static public var buffer:Buffer<DepthPerPixel>;
	static public var program:Program;
	
	static public function init(display:Display, tilesTexture:Texture)
	{	
		buffer = new Buffer<DepthPerPixel>(8, 8, true);
		program = new Program(buffer);
				
		// create a texture-layer named "tiles"
		program.setTexture(tilesTexture, "tiles", false);

		program.injectIntoFragmentShader(
		"
			vec4 depthPerPixel( vec4 tilesColor, float depth )
			{
				//gl_FragDepth = (tilesColor.b + depth);
				
				if (tilesColor.b < 1.0)	gl_FragDepth = ( tilesColor.b / 3.0 + depth);
				else gl_FragDepth =  1.0;
				
				return vec4(tilesColor.r, tilesColor.r, tilesColor.r, tilesColor.a);
			}
		");
		
		// instead of using the named or the default "base" identifier to get the texture-color
		// the "_ID" postfix is to give access to use getTextureColor() manually 
		// from inside of the glsl depthPerPixel() function to access texture-pixels
				
		program.setColorFormula( "depthPerPixel(tiles, depth)" );
				
		program.zIndexEnabled= true;
		
		program.blendEnabled = true;
		
		//program.discardAtAlpha(null);
		program.discardAtAlpha(0.001);
				
		display.addProgram(program);
	}
	
	
	
	public function new(x:Int, y:Int, w:Int, h:Int, tile:Int, depth:Float = 1/3)
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.tile = tile;
		this.depth = depth;
		
		buffer.addElement(this);
	}

	public function update()
	{
		buffer.updateElement(this);
	}

}
