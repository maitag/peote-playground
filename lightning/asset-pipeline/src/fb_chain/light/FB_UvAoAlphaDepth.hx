package fb_chain.light;

import peote.view.*;
import peote.view.intern.BufferInterface;

@:forward
abstract FB_UvAoAlphaDepth(Display) to Display
{
	public function new(w:Int, h:Int, buffer:BufferInterface, normalDepthTextures:Array<Texture>, uvAoAlphaTextures:Array<Texture>, haxeUVTexture:Texture)
	{	
		this = new Display(0, 0, w, h);
		
		var program = new Program(buffer);
		
		program.autoUpdate = false;
		program.setMultiTexture(normalDepthTextures, "normalDepth");
		program.setMultiTexture(uvAoAlphaTextures, "uvAoAlpha");
		program.setTexture(haxeUVTexture, "haxeUV");
		
		program.injectIntoFragmentShader(
		"	
			vec4 uvAoAlphaDepth( vec4 normalDepthTexture, vec4 uvAoAlphaTexture, int haxeUVTextureID, float depth)
			{
				// z-buffer
				if (normalDepthTexture.a < 1.0) gl_FragDepth = ( normalDepthTexture.a / 3.0 + depth);
				// if (normalDepthTexture.a < 1.0) gl_FragDepth = ( normalDepthTexture.a + depth);
				else gl_FragDepth =  1.0;
				
				vec4 uvTex = getTextureColor( haxeUVTextureID, vec2(uvAoAlphaTexture.r, uvAoAlphaTexture.g) );

				// global mapping for testing purpose
				// vec4 uvTex = getTextureColor( haxeUVTextureID, vec2(vTexCoord.x, vTexCoord.y) );

				// return vec4( uvTex.rgb * uvAoAlphaTexture.b, uvTex.a * uvAoAlphaTexture.a );
				// return vec4( vec3(1.0,1.0,1.0) * uvAoAlphaTexture.b, uvAoAlphaTexture.a );
				// return vec4( vec3(0.1,0.1,0.1), uvAoAlphaTexture.a );
				return vec4( vec3(0.0,0.0,0.0), uvAoAlphaTexture.a );

				// testing uv-map:
				// return vec4( uvAoAlphaTexture.r, uvAoAlphaTexture.g, 0.0, uvAoAlphaTexture.a );
			}
		");
		
		program.setColorFormula( "uvAoAlphaDepth(normalDepth, uvAoAlpha, haxeUV_ID, depth)", true);
		
		program.zIndexEnabled= true;
		program.blendEnabled = true;
		
		this.addProgram(program);
	}
}
