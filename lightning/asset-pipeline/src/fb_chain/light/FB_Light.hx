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
			
// Rotation um die X-Achse
vec3 rotateX(vec3 v, float angleDegrees) {
    float angleRad = radians(angleDegrees);
    float c = cos(angleRad);
    float s = sin(angleRad);
    mat3 m = mat3(
        1.0, 0.0, 0.0,
        0.0,   c,  -s,
        0.0,   s,   c
    );
    return m * v;
}
// Rotation um die Y-Achse
vec3 rotateY(vec3 v, float angleDegrees) {
    float angleRad = radians(angleDegrees);
    float c = cos(angleRad);
    float s = sin(angleRad);
    mat3 m = mat3(
          c, 0.0,   s,
        0.0, 1.0, 0.0,
         -s, 0.0,   c
    );
    return m * v;
}
// Rotation um die Z-Achse
vec3 rotateZ(vec3 v, float angleDegrees) {
    float angleRad = radians(angleDegrees);
    float c = cos(angleRad);
    float s = sin(angleRad);
    mat3 m = mat3(
          c,  -s, 0.0,
          s,   c, 0.0,
        0.0, 0.0, 1.0
    );
    return m * v;
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
				vec3 light = vec3(  vTexCoord - 0.5, normalTextureRGBZ.a - depth  );
				// vec3 light = vec3(  vec2(0.5-vTexCoord.x , 0.5-vTexCoord.y) , normalTextureRGBZ.a - depth );
				// debug
				// light = rotateX(light, u_debug0);//light.x=-light.x;
				// light = rotateY(light, u_debug1);//light.y=-light.y;
				// light = rotateZ(light, u_debug2);//light.z=-light.z;
				
				float D = length(light);
				// D = max(D, 0.05); 

				//normalize light vector
				vec3 L = normalize(light);


				// calculate the light falloff
				// float attenuation = 1.0 / ( falloff.x + (falloff.y * D) + (falloff.z * D * D) );
				// float attenuation = clamp(1.0 - D * D / (0.5 * 0.5), 0.0, 1.0); attenuation *= attenuation;
				float attenuation = max(1.0 - D * D / (0.25), 0.0); attenuation *= attenuation;
				// attenuation = 1.0; // <- debug


				// no normalize here because it is did already (+rotated!) by ProgramNormal-shader
				vec3 N = normalTextureRGBZ.xyz;
				// vec3 N = normalTextureRGBZ.xyz * 2.0 - 1.0;
				// N = vec3(0.0, 0.0, 1.0); // <- to debug the GLICTH
				
				// TODO: check rotating the normals to fix GLITCH -> and do in blender-compositor!
				// N = rotateX(N, u_debug0);// N.x=-N.x;
				// N = rotateY(N, u_debug1);// N.y=-N.y;
				// N = rotateZ(N, u_debug2);// N.z=-N.z;
				// dirty fix:
				N = rotateX(N, -25.0); // dont ask my why that values *lol
				N = rotateY(N, 25.0);
				// rotate or mirror here: N = rotateZ(N, -180.0);
				N.x = -N.x;	N.y = -N.y;

				// N = normalize(N);

				// dot product to determine diffuse by light and face-normal direction
				vec3 diffuse = lightColor * max( dot(N, L),  0.0);
				// vec3 diffuse = abs( dot(N, L) ); // <- to debug the GLICTH
				// vec3 diffuse = lightColor * max( dot(N, L),  0.0);
	
				// add the final attenuated light to the ambientColor
				vec3 intensity = ambientColor + diffuse * attenuation;
	
				// return vec4(normalTextureRGBZ.a*vec3(3.0,3.0,3.0), 1.0); // to test the depth-mapping
				// return vec4(normalTextureRGBZ.xyz, 1.0); // to test the normal-mapping
				// return vec4(N, 1.0); // to test the normal-mapping
				// return vec4(vTexCoord.x*2.0-1.0 ,0.0,vTexCoord.y*2.0-1.0 , 1.0); // to test light-space
				return vec4(intensity, 1.0);
			}
		',
		[
			"u_debug0"=>Main.u_debug0,
			"u_debug1"=>Main.u_debug1,
			"u_debug2"=>Main.u_debug2,
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
