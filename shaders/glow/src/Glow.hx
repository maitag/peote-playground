package;

import peote.view.Color;
import peote.view.intern.BufferInterface;
import peote.view.Texture;
import peote.view.Program;
import peote.view.Element;

class Glow implements Element
{
	// position
	@posX public var x:Int = 0;
	@posY public var y:Int = 0;
	
	// size
	@sizeX public var w:Int = 256;
	@sizeY public var h:Int = 256;

	// color
	@color public var c:Color = 0x775511ff;


	// TODO: some custom vars for the shader 


	// ---- animated by shader ----
	// texture tile number
	@texTile @anim("Tile", "repeat")
	public var tile:Int = 0;
	
	var OPTIONS = { blend:true };

	public function new(x:Int = 0, y:Int = 0, w:Int = 256, h:Int = 256) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		// still let them walk:
		animTile(0, 23);    // params: start-tile, end-tile
		timeTile(0.0, 1.4); // params: start-time, duration				
	}


	// --------------------------------------------------------------------------
	// --------------------------------------------------------------------------
	// --------------------------------------------------------------------------

	static public function createProgram(buffer:BufferInterface, texture:Texture):Program
	{	
		var program = new Program(buffer);
		
		// create a texture-layer named "base"
		program.setTexture(texture, "base", true);

		program.injectIntoFragmentShader(
		"	
			// origin from here: https://www.shadertoy.com/view/MdSyD1

			const float radius = 16.0;
			const vec3 glowColor = vec3(0.9, 0.2, 0.0);
			const float sweepRate = 25.0;
			const float pi = 3.14159265358979323846;
			const float timeFactor = 3.0;
			const float halfTimeFactor = timeFactor * 0.5;

			float coefficient()
			{
				float v = mod(uTime, timeFactor);
				if(v > halfTimeFactor)
					v = timeFactor - v;
				return v;
			}

			vec4 glow( int textureID )
			{
				vec4 texel = getTextureColor(textureID, vTexCoord);
				vec4 color = vec4(0.0);
				float density = 0.0;

				if(texel.a >= 1.0)
					color = vec4(texel.rgb, 1.0);
				else
				{
					for(float i = 0.0; i < 360.0; i += sweepRate)
					{
						vec2 texRes = getTextureResolution(textureID);
						float xi = radius * cos(pi * i / 180.0) / texRes.x;
						float yi = radius * sin(pi * i / 180.0) / texRes.y;
						
						density += getTextureColor(textureID, vec2(vTexCoord.x + xi, vTexCoord.y + yi)).a;
						density += getTextureColor(textureID, vec2(vTexCoord.x - xi, vTexCoord.y + yi)).a;
						density += getTextureColor(textureID, vec2(vTexCoord.x - xi, vTexCoord.y - yi)).a;
						density += getTextureColor(textureID, vec2(vTexCoord.x + xi, vTexCoord.y - yi)).a;
					}
					color = vec4(glowColor * density / radius * coefficient(), 1.0);
					color += vec4(texel.rgb * texel.a, texel.a);
				}

				return color;
			}			
		",
		true, false);
		
		// instead of using normal "base" identifier to get the texture-color
		// the "_ID" postfix is to give access to use getTextureColor() manually 
		// from inside of the glsl blur() function to that texture-layer
		
		program.setColorFormula( "c0 * glow(base_ID)" );
		
		// this also works if has "base" inside DEFAULT_FORMULA_VARS
		//program.setColorFormula( 'blur(${GLOW.TEXTURE_ID_base})' );

		return program;
	}
}
