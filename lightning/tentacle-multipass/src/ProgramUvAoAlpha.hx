package;

import peote.view.*;

class ProgramUvAoAlpha extends Program
{
	public function new(buffer:Buffer<ElementTentacle>, normalDepthTexture:Texture, uvAoAlphaTexture:Texture, haxeUVTexture:Texture)
	{	
		super(buffer);
		
		setTexture(normalDepthTexture, "normalDepth", false);
		setTexture(uvAoAlphaTexture, "uvAoAlpha", false);
		setTexture(haxeUVTexture, "haxeUV", false);
		
		injectIntoFragmentShader(
		"	
			vec4 gimmeColor( vec4 normalDepthTexture, vec4 uvAoAlphaTexture, int haxeUVTextureID, float depth)
			{
				// z-buffer
				if (normalDepthTexture.a < 1.0) gl_FragDepth = ( normalDepthTexture.a / 3.0 + depth);
				else gl_FragDepth =  1.0;

				vec4 uvTex = getTextureColor( haxeUVTextureID, vec2(uvAoAlphaTexture.r, uvAoAlphaTexture.g) );

				// global mapping for testing purpose
				// vec4 uvTex = getTextureColor( haxeUVTextureID, vec2(vTexCoord.x, vTexCoord.y) );

				return vec4(  uvTex.rgb * uvAoAlphaTexture.b, uvTex.a * uvAoAlphaTexture.a);

				// testing uv-map:
				// return vec4( uvAoAlphaTexture.r, uvAoAlphaTexture.g, 0.0, uvAoAlphaTexture.a );
			}
		");
		
		setColorFormula( "gimmeColor(normalDepth, uvAoAlpha, haxeUV_ID, depth)" );
		
		zIndexEnabled= true;
		blendEnabled = true;
	}

}
