package fb_chain.light;

import peote.view.*;
import peote.view.intern.BufferInterface;

@:forward
abstract FB_NormalDepth(Display) to Display
{
	public function new(w:Int, h:Int, buffer:BufferInterface, normalDepthTextures:Array<Texture>, useFloatNormals:Bool, usePackedNormals:Bool)
	{	
		this = new Display(0, 0, w, h);
		
		var program = new Program(buffer);
		
		program.autoUpdate = false;
		program.setMultiTexture(normalDepthTextures, "normalDepth");

		// program.setFragmentFloatPrecision("high");
		// program.setFragmentSamplerPrecision("high");
	
		program.injectIntoFragmentShader(
		(usePackedNormals) ?
		'	
			${ShaderFunc.rotate}
			vec4 normalDepthAlpha( vec4 normalDepthTex, float depth)
			{
				vec3 N = vec3(0.0, 0.0, 0.0);;

				// z-buffer
				if (normalDepthTex.b < 0.99)
				// if (normalDepthTex.b < 1.0)
				{
					// TODO: scale factor in depend of size, by split the depth component or by extra attribute!
					gl_FragDepth = ( normalDepthTex.b * 0.5 + 0.5); //range [0.5, 1.0]
					// gl_FragDepth += depth;
					gl_FragDepth += depth + 0.01;
					
					N.xy = normalDepthTex.xy * 2.0 - 1.0;

					// OPTIMIZATION: for packed xy-only normalmap (look at blender file!)
					N.z = -sqrt(max(0.0, 1.0 - dot(N.xy, N.xy))); // <--- by reconstructing z value
					// N.z = -sqrt(max(0.01,1.0 - dot(N.xy, N.xy) )); // <--- by reconstructing z value
					// N.z = -sqrt(max(0.0, 1.0 - min(dot(N.xy, N.xy), 0.9) )); // <--- by reconstructing z value
					// N = normalize(N);

					// ROTATE it in depend of element-rotation
					N.xy = rotate(N.xy, vRotZ.x);

					// DEBUG 
					N = debugNormale(N);
				}
				else gl_FragDepth = 1.0;

				${(useFloatNormals) ? "
				return vec4(N, gl_FragDepth * 2.0 - 1.0); // <--- FLOAT_RGBA texture format
				" : "
				return vec4(N*0.5+0.5, gl_FragDepth); // <--- RGBA texture format 
				"}

				// to test normal map separate into FBO-chain
				// return vec4(normalDepthTex.xyz, 1.0);
			}
		' :
		'	
			${ShaderFunc.rotate}
			vec4 normalDepthAlpha( vec4 normalDepthTex, float depth)
			{
				vec3 N;

				// z-buffer
				if (normalDepthTex.a < 1.0)
				{
					// TODO: scale factor in depend of size, by split the depth component or by extra attribute!
					// gl_FragDepth = ( normalDepthTex.a / 3.0 + depth);
					// gl_FragDepth = ( normalDepthTex.a * 2.0 - 1.0 ); // unpack from range [0.5, 1.0] to [0.0, 1.0]
					// gl_FragDepth = ( normalDepthTex.a - 0.5 ); // unpack into range [0.0, 0.5]
					gl_FragDepth = ( normalDepthTex.a ); //range [0.5, 1.0]
					gl_FragDepth += depth;
					
					N = normalDepthTex.xyz * 2.0 - 1.0;
					
					// ROTATE it in depend of element-rotation
					N.xy = rotate(N.xy, vRotZ.x);

					// DEBUG 
					N = debugNormale(N);
				}
				else gl_FragDepth = 1.0;

				${(useFloatNormals) ? "
				return vec4(N, gl_FragDepth * 2.0 - 1.0); // <--- FLOAT_RGBA texture format for depth>0.5 mapped by blender
				" : "
				return vec4(N*0.5+0.5, gl_FragDepth); // <--- RGBA texture format for depth>0.5 mapped by blender
				"}

				// to test normal map separate into FBO-chain
				// return vec4(normalDepthTex.xyz, 1.0);
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

		#if peoteview_debug_shader
		program.debugShader = true;
		#end
		
		this.addProgram(program);
	}

}
