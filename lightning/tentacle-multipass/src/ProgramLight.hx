package;

import peote.view.*;

class ProgramLight extends Program
{
	public function new(buffer:Buffer<ElementLight>, normalDisplayTexture:Texture)
	{	
		super(buffer);
		
		// create texture-layer
		setTexture(normalDisplayTexture, "normalDisplay", false);

		injectIntoFragmentShader(
		"	
			vec4 normalLight( int normalTextureID, float depth )
			{
				vec3 lightColor = vec3(1.0, 1.0, 1.0);
				vec3 ambientColor = vec3(0.0, 0.0, 0.0);
				vec3 falloff = vec3(0.4, 3.0, 20.0); // TODO: in depend of size!
				
				// WARNING: returns allways the full texture-size, so the power-of-2 one!
				vec2 texRes = getTextureResolution(normalTextureID);
				
				// fetch pixel from normal-map
				vec4 normalTextureRGBZ = getTextureColor( normalTextureID, (vPos + (vTexCoord - 0.5)*vSize)/texRes );
				
				
				// vector to position of light
				vec3 light = vec3(  vTexCoord - 0.5 ,  normalTextureRGBZ.a - depth );
				
				float D = length(light);
				// calculate the light falloff
				//float attenuation = 1.0 / ( falloff.x + (falloff.y * D) + (falloff.z * D * D) );
				//float attenuation = clamp(1.0 - D * D / (0.5 * 0.5), 0.0, 1.0);
				float attenuation = max(1.0 - D * D / (0.25), 0.0);
				attenuation *= attenuation;

				// no normalize here because it is did already (+rotated!) by ProgramNormal-shader
				// vec3 N = normalize(normalTextureRGBZ.rgb * 2.0 - 1.0);
				vec3 N = normalTextureRGBZ.rgb;
				
				//normalize light vector
				vec3 L = normalize(light);
				
				//  dot product to determine diffuse by light and face-normal direction
				vec3 diffuse = lightColor * max( dot(N, L), 0.0);
	
				// add the final attenuated light to the ambientColor
				vec3 intensity = ambientColor + diffuse * attenuation;
	
				// return vec4(normalTextureRGBZ.rgb, 1.0); // to test the normal-mapping
				return vec4(intensity, 1.0);
			}			
		");
		
		// instead of using normal "base" identifier to get the texture-color
		// the "_ID" postfix is to give access to use getTextureColor() manually 
		// from inside of the glsl blur() function to that texture-layer
		
		setColorFormula( "color*normalLight(normalDisplay_ID, depth)" );

		// blending to "add" multiple lights
		blendEnabled = true;
		blendSrc = BlendFactor.ONE;
		blendDst = BlendFactor.ONE;				
	}
	

}
