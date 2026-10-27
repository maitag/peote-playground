package fb_chain.light;

import peote.view.*;
import peote.view.intern.BufferInterface;

@:forward
abstract FB_UvAoAlphaDepth(Display) to Display
{
	public function new(w:Int, h:Int, buffer:BufferInterface, normalDepthTextures:Array<Texture>, uvAoAlphaTextures:Array<Texture>, haxeUVTexture:Texture, usePackedNormals:Bool)
	{	
		this = new Display(0, 0, w, h);
		
		var program = new Program(buffer);
		
		program.autoUpdate = false;
		program.setMultiTexture(normalDepthTextures, "normalDepth");
		program.setMultiTexture(uvAoAlphaTextures, "uvAoAlpha");
		program.setTexture(haxeUVTexture, "haxeUV");
		
		program.injectIntoFragmentShader(
		'	
			vec4 uvAoAlphaDepth( vec4 normalDepthTex, vec4 uvAoAlphaTexture, int haxeUVTextureID, float depth)
			{
				// z-buffer
				${(usePackedNormals)
					? "if (normalDepthTex.b < 1.0) gl_FragDepth = ( depth + normalDepthTex.b * 0.5 + 0.5); // unpack into range [0.5, 1.0]"
					: "if (normalDepthTex.a < 1.0) gl_FragDepth = ( depth + normalDepthTex.a); // unpack into range [0.5, 1.0]"
				}
				else gl_FragDepth =  1.0;
				
				vec4 uvTex = getTextureColor( haxeUVTextureID, vec2(uvAoAlphaTexture.r, uvAoAlphaTexture.g) );

				// global mapping for testing purpose
				// vec4 uvTex = getTextureColor( haxeUVTextureID, vec2(vTexCoord.x, vTexCoord.y) );

				// return vec4( uvTex.rgb * uvAoAlphaTexture.b, uvTex.a * uvAoAlphaTexture.a );
				// return vec4( vec3(1.0,1.0,1.0) * uvAoAlphaTexture.b, uvAoAlphaTexture.a );
				return vec4( vec3(0.1,0.1,0.1) * uvAoAlphaTexture.b, uvAoAlphaTexture.a );
				// return vec4( vec3(0.0,0.0,0.0), uvAoAlphaTexture.a );

				// testing uv-map:
				// return vec4( uvAoAlphaTexture.r, uvAoAlphaTexture.g, 0.0, uvAoAlphaTexture.a );
			}
		');
		
		program.setColorFormula( "uvAoAlphaDepth(normalDepth, uvAoAlpha, haxeUV_ID, depth)", true);
		
		program.zIndexEnabled= true;
		program.blendEnabled = true;
		
		this.addProgram(program);
	}
}
