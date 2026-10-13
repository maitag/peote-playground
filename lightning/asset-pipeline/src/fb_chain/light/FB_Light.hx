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

				vec3 lightColor = vec3(1.0, 1.0, 1.0);
				vec3 ambientColor = vec3(0.0, 0.0, 0.0);
				vec3 falloff = vec3(0.4, 3.0, 20.0); // TODO: in depend of size!
				
				// WARNING: returns allways the full texture-size, so the power-of-2 one!
				// vec2 texRes = getTextureResolution(normalDepthID);
				vec2 texRes = getTextureResolution(normalDepthID) / displayZoom;
				
				// fetch pixel from normal-map
				// vec4 normalTextureRGBZ = getTextureColor( normalDepthID, (vPos + (vTexCoord - 0.5)*vSize)/texRes );
               	vec4 normalTextureRGBZ = getTextureColor( normalDepthID, (displayOffset + vPos + (vTexCoord - 0.5)*vSize)/texRes );
				
				
				// vector to position of light
				vec3 light = vec3(  vTexCoord - 0.5 ,  normalTextureRGBZ.a - depth );
				// vec3 light = vec3(  vec2(0.5-vTexCoord.x , vTexCoord.y-0.5) ,  normalTextureRGBZ.a - depth);
				// vec3 light = vec3(  vTexCoord - 0.5 ,  0.01 ); // <- to debug the GLICTH
				

				float D = length(light);
				// D = max(D, 0.05); 

				// calculate the light falloff
				// float attenuation = 1.0 / ( falloff.x + (falloff.y * D) + (falloff.z * D * D) );
				// float attenuation = clamp(1.0 - D * D / (0.5 * 0.5), 0.0, 1.0);
				float attenuation = max(1.0 - D * D / (0.25), 0.0);
				attenuation *= attenuation;

				// no normalize here because it is did already (+rotated!) by ProgramNormal-shader
				// vec3 N = normalize(normalTextureRGBZ.rgb * 2.0 - 1.0);
				vec3 N = normalTextureRGBZ.rgb;
				// N = vec3(N.y, N.x, N.z);
				// vec3 N = vec3(0.0, 0.0, 1.0); // <- to debug the GLICTH
				

				//normalize light vector
				vec3 L = normalize(light);
				
				//  dot product to determine diffuse by light and face-normal direction
				vec3 diffuse = lightColor * max( dot(N, L), 0.0);
				// vec3 diffuse = lightColor * abs( dot(N, L) ); // <- to debug the GLICTH
	
				// add the final attenuated light to the ambientColor
				vec3 intensity = ambientColor + diffuse * attenuation;
	
				// return vec4(normalTextureRGBZ.rgb, 1.0); // to test the normal-mapping
				return vec4(intensity, 1.0);
			}
		');
				
		program.setColorFormula( "color*normalLight(normalDepth_ID, depth)", true);

		// blending to "add" multiple lights
		program.blendEnabled = true;
		program.blendSrc = BlendFactor.ONE;
		program.blendDst = BlendFactor.ONE;				
		
		this.addProgram(program);

	}
}
