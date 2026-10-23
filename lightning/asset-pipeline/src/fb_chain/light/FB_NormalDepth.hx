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
			'	
			${ShaderFunc.rotate}

			vec2 rotate(vec2 v, float a) {
				float s = sin(a);
				float c = cos(a);
				mat2 m = mat2(c, s, -s, c);
				return m * v;
			}
			
			vec4 normalDepthAlpha( vec4 normalDepthTex, float depth)
			{
				vec3 N;

				// z-buffer
				if (normalDepthTex.a < 1.0)
				{
					// TODO: scale factor in depend of size, by split the depth component or by extra attribute!
					// gl_FragDepth = ( normalDepthTex.a / 3.0 + depth);
					gl_FragDepth = ( normalDepthTex.a + depth);
					// gl_FragDepth = ( u_debug0 + depth);
					
					N = normalDepthTex.xyz * 2.0 - 1.0;

					// OPTIMIZATION: for packed xy-only normalmap (look at blender file!)
					// N.z = sqrt(max(0.0, 1.0 - dot(N.xy, N.xy))); // <--- by reconstructing z value
					
					// ROTATE it in depend of element-rotation
					N.xy = rotate(N.xy, vRotZ.x);


					// ------- DEBUG -------
					N = rotateX(N, u_debug_rotate.x);
					N = rotateY(N, u_debug_rotate.y);
					N = rotateZ(N, u_debug_rotate.z);
					
					if (u_debug_swap==1) N.xyz = N.xzy;
					if (u_debug_swap==2) N.xyz = N.yxz;
					if (u_debug_swap==3) N.xyz = N.yzx;
					if (u_debug_swap==4) N.xyz = N.zxy;
					if (u_debug_swap==5) N.xyz = N.zyx;
					
					if (u_debug_invert.x==1) N.x=-N.x;
					if (u_debug_invert.y==1) N.y=-N.y;
					if (u_debug_invert.z==1) N.z=-N.z;

					// N = normalize(N); // <----- is NEED for OVERNORMALIZATION ? lol^^
					
				}
				else gl_FragDepth = 1.0; 

				// return vec4(N, gl_FragDepth); // <--- FLOAT_RGBA texture format
				return vec4(N*0.5+0.5, gl_FragDepth*0.5+0.5);
			}
		',
		[
			"u_debug_rotate"=>Main.u_debug_rotate,
			"u_debug_invert"=>Main.u_debug_invert,
			"u_debug_swap"=>Main.u_debug_swap,
		]
		);
				
		program.setColorFormula( "normalDepthAlpha(normalDepth, depth)", true);
		
		program.zIndexEnabled= true;
		program.blendEnabled = false;
		
		this.addProgram(program);
	}

}
