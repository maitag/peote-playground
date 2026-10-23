package fb_chain.light;

import peote.view.*;
import peote.view.intern.BufferInterface;

@:forward
abstract FB_Light(Display) to Display
{
	public function new(w:Int, h:Int, buffer:BufferInterface, normalDepthTexture:Texture)
	{	
		this = new Display(0, 0, w, h);
		
		var program = new Program(buffer);
		
		program.autoUpdate = false;
		program.setTexture(normalDepthTexture, "normalDepth");
		
		// for HTML5 (without it can not link the UBOs between vertex and fragmentshader)
		if (PeoteGL.Version.isES3) program.setFragmentFloatPrecision("high");
		
		program.injectIntoFragmentShader('
			${ (PeoteGL.Version.isES3) ? // UBOs for HTML5
			"uniform uboView { vec2 uResolution; vec2 uViewOffset; vec2 uViewZoom; };
			 uniform uboDisplay { vec2 uOffset; vec2 uZoom; };"
			:
			"uniform vec2 uResolution; uniform vec2 uOffset; uniform vec2 uZoom;"
			}
			
			${ShaderFunc.rotate}

			vec4 normalLight( int normalDepthID, float depth )
			{
				${ (PeoteGL.Version.isES3) ? // UBOs for HTML5
				"float displayZoom = uZoom.y*uViewZoom.y;
				 vec2 displayOffset = vec2((uViewOffset.x+uOffset.x) / uZoom.x, (uViewOffset.y+uOffset.y) / uZoom.x - uResolution.y/displayZoom);
				" :
				"float displayZoom = uZoom.x;
				 vec2 displayOffset = vec2(uOffset.x, uOffset.y - uResolution.y/displayZoom);
				"
				}

				// TODO:
				vec3 lightColor = vec3(1.0, 1.0, 1.0);
				vec3 ambientColor = vec3(0.0, 0.0, 0.0);
				vec3 falloff = vec3(0.4, 3.0, 20.0); // TODO: in depend of size!
				
				// WARNING: returns allways the full texture-size, so the power-of-2 one!
				// vec2 texRes = getTextureResolution(normalDepthID);
				vec2 texRes = getTextureResolution(normalDepthID) / displayZoom;

				
				// ----- fetch pixel from beforehand FB_NormalDepth pass ------
				// vec4 normalTextureRGBZ = getTextureColor( normalDepthID, (vPos + (vTexCoord - 0.5)*vSize)/texRes );
               	vec4 normalTextureRGBZ = getTextureColor( normalDepthID, (displayOffset + vPos + (vTexCoord - 0.5)*vSize)/texRes );				
				normalTextureRGBZ = normalTextureRGBZ * 2.0 - 1.0; // <----- comment this out for FLOAT_RGBA fbo-textureformat
               					
				// ----- light-vector from light-elements origin to position of normal-map ones
				vec3 light = vec3(  0.5 - vTexCoord , depth - normalTextureRGBZ.a );
				
					
				// ----- light falloff (attenuation) ----
				float D = length(light);
				// float attenuation = 1.0 / ( falloff.x + (falloff.y * D) + (falloff.z * D * D) );
				// float attenuation = clamp(1.0 - D * D / (0.5 * 0.5), 0.0, 1.0); attenuation *= attenuation;
				float attenuation = max(1.0 - D * D / (0.25), 0.0); attenuation *= attenuation;
				// attenuation = 1.0; // <- debug


				// Face NORMALE
				vec3 N = normalTextureRGBZ.xyz;  // N = normalize(N); // N = vec3(0.0, 0.0, -1.0); // <- to debug
				
				// Light NORMALE
				vec3 L = normalize(light);

				// DIFFUSE (dot product to determine diffuse by light and face-normal direction)
				vec3 diffuse = lightColor * max( dot(N, L),  0.0); // TODO: try 0.1 for more into ambient-space!
				
    
				// TODO: ------ phong specular -------				
				// vec3 LR = reflect(-L,N); // <- reflect the light vector at surface normale
				// LR = normalize(LR);
				// float spec = pow(max(dot(vec3(0.0, 0.0, 1.0), LR), 0.0), 32.0); // 32.0 = Schärfe des Glanzpunktes
				// vec3 specular = specColor * spec * normalTextureRGBZ.a * attenuation;
				

				// COMBINE final light with ambient (and specular <-TODO:)
				vec3 intensity = ambientColor + diffuse * attenuation; // + specular

				
				// return vec4(vec3(normalTextureRGBZ.a), 1.0); // to test the depth-map
				// return vec4(normalTextureRGBZ.xyz, 1.0); // to test that normal-map is same as inside of blender
				// return vec4(vTexCoord.x*2.0-1.0 ,0.0,vTexCoord.y*2.0-1.0 , 1.0); // to test light-space
				// return vec4(vTexCoord.x-0.5 ,0.0,vTexCoord.y-0.5 , 1.0); // to test light-space
				return vec4(intensity, 1.0);
			}
		',
		[
			"u_debug_rotate"=>Main.u_debug_rotate,
			"u_debug_invert"=>Main.u_debug_invert,
			"u_debug_swap"=>Main.u_debug_swap,
		]
		);
				
		program.setColorFormula( "color*normalLight(normalDepth_ID, depth)", true);
		// program.setColorFormula( "normalLight(normalDepth_ID, depth)", true);

		// blending to "add" multiple lights
		program.blendEnabled = true;
		program.blendSrc = BlendFactor.ONE;
		program.blendDst = BlendFactor.ONE;				
		
		this.addProgram(program);

	}
}
