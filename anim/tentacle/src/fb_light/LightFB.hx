package fb_light;

import peote.view.*;
import peote.view.intern.BufferInterface;

@:forward(x, y, width, height)
abstract LightFB(Display) to Display
{
	public function new(w:Int, h:Int, buffer:BufferInterface, normalDepthTexture:Texture)
	{	
		this = new Display(0, 0, w, h);
		
		var program = new Program(buffer);
		
		program.setTexture(normalDepthTexture, "normalDepth", false);
		
		program.injectIntoFragmentShader(
			"	
			vec4 normalLight( int normalDepthID, float depth )
			{
				vec3 lightColor = vec3(1.0, 1.0, 1.0);
				vec3 ambientColor = vec3(0.0, 0.0, 0.0);
				vec3 falloff = vec3(0.4, 3.0, 20.0); // TODO: in depend of size!
				
				// WARNING: returns allways the full texture-size, so the power-of-2 one!
				vec2 texRes = getTextureResolution(normalDepthID);
				
				// fetch pixel from normal-map
				vec4 normalTextureRGBZ = getTextureColor( normalDepthID, (vPos + (vTexCoord - 0.5)*vSize)/texRes );
				
				
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
				
		program.setColorFormula( "color*normalLight(normalDepth_ID, depth)" );

		// blending to "add" multiple lights
		program.blendEnabled = true;
		program.blendSrc = BlendFactor.ONE;
		program.blendDst = BlendFactor.ONE;				
		
		this.addProgram(program);
	}

	public inline function addToPeoteView(peoteView:PeoteView, ?atDisplay:Display, addBefore:Bool=false)
	{
		if (texture == null) this.setFramebuffer(new Texture(this.width, this.height, 1, {format:TextureFormat.RGB, smoothExpand: false, smoothShrink: false, powerOfTwo: false} ), peoteView);
		this.addToPeoteViewFramebuffer(peoteView, atDisplay, addBefore);
	}

	public inline function removeFromPeoteView(peoteView:PeoteView) this.removeFromPeoteViewFramebuffer(peoteView);
	
	public var texture(get, never):Texture;
	@:access(peote.view.Display) inline function get_texture():Texture return this.fbTexture;
}
