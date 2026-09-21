package fb_chain.light;

import peote.view.*;
import peote.view.intern.BufferInterface;

@:forward
abstract FB_NormalDepth(Display) to Display
{
	public function new(w:Int, h:Int, buffer:BufferInterface, normalDepthTextures:Array<Texture>)
	{	
		this = new Display(0, 0, w, h);
		
		var program = new Program(buffer);
		
		program.autoUpdate = false;
		program.setMultiTexture(normalDepthTextures, "normalDepth");
		
		program.injectIntoFragmentShader(
			"	
			vec2 rotate(vec2 v, float a) {
				float s = sin(a);
				float c = -cos(a);
				mat2 m = mat2(c, -s, s, c);
				return m * v;
			}

			vec4 normalDepthAlpha( vec4 normalDepthTex, float depth)
			{
				// flip x normal (depends on uv-map generation variants)
				// normalDepthTex.r = 1.0 - normalDepthTex.r;
				// normalDepthTex.g = 1.0 - normalDepthTex.g;
				// normalDepthTex.b = 1.0 - normalDepthTex.b;

				// little hack to mirror horizontally use a negative rotation (to flip x normal)
				// if (vRotZ.x < 0.0) normalDepthTex.r = 1.0 - normalDepthTex.r;
				
				vec3 N;

				// z-buffer
				if (normalDepthTex.a < 1.0)
				{
					// TODO: scale factor in depend of size, by split the depth component or by extra attribute!
					gl_FragDepth = ( normalDepthTex.a / 3.0 + depth);
					// gl_FragDepth = ( normalDepthTex.a + depth);
					

					// normalize and rotate vector
					// N = normalDepthTex.xyz;
					N = normalize(normalDepthTex.xyz * 2.0 - 1.0);

					// TODO: look into blender how to flip the normals for rotation here
					// N.xy = rotate(N.xy, vRotZ.x);
				}
				else gl_FragDepth =  1.0; 


				// return vec4(N.x, N.y, N.z, normalDepthTex.a);
				return vec4(N.x, N.y, N.z, gl_FragDepth);
			}
		");
				
		program.setColorFormula( "normalDepthAlpha(normalDepth, depth)", true);
		
		program.zIndexEnabled= true;
		program.blendEnabled = false;
		
		this.addProgram(program);
	}
}
