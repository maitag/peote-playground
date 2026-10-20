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
				// float c = cos(a);
				// mat2 m = mat2(c, s, -s, c);
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
					// gl_FragDepth = ( u_debug0 + depth);
					

					// normalize and rotate vector
					N = normalDepthTex.xyz * 2.0 - 1.0;
					
					// if (length(N) < 0.05) N = vec3(0.0, 0.0, 1.0); // flattn it and point it upwards here
					// N.z = N.z * u_debug0;
					
					// LOOK into blender how to flip the normals if use of EXTRA rotation here:
					// N.xy = rotate(N.xy, vRotZ.x);
										
					N = normalize(N);
				}
				else gl_FragDepth = 1.0; 


				// return vec4(N.x, N.y, N.z, normalDepthTex.a);
				// return vec4(N.x,N.z,N.y, gl_FragDepth);
				return vec4(N, gl_FragDepth);
			}
		",
		[
			"u_debug0"=>Main.u_debug0,
			"u_debug1"=>Main.u_debug1,
			"u_debug2"=>Main.u_debug2,
		]
		);
				
		program.setColorFormula( "normalDepthAlpha(normalDepth, depth)", true);
		
		program.zIndexEnabled= true;
		program.blendEnabled = false;
		
		this.addProgram(program);
	}

}
