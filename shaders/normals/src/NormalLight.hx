package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Texture;
import peote.view.utils.BlendMode;

class NormalLight implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@varying @posX public var x:Int = 50;
	@varying @posY public var y:Int = 50;
	
	@varying @custom public var depth:Float = 0.25;
	
	// size in pixel
	@varying @sizeX public var size:Int = 100;
	@sizeY @const @formula("size") var h:Int;
	
	@pivotX @const @formula("size * 0.5") var px:Int;
	@pivotY @const @formula("size * 0.5") var py:Int;
	

	// TODO:
	//var DEFAULT_FRAGMENT_SHADER = "";	
	//var DEFAULT_COLOR_FORMULA = "blur(base_ID)";
	
	//var DEFAULT_FORMULA_VARS = ["base"  => 0xff0000ff];
	// --------------------------------------------------------------------------
	
	static public var buffer:Buffer<NormalLight>;
	static public var program:Program;
	
	static public function init(display:Display, lightsTexture:Texture, normalTexture:Texture)
	{	
		buffer = new Buffer<NormalLight>(8, 8, true);
		program = new Program(buffer);
		
		// create a texture-layer named "base"
		program.setTexture(lightsTexture, "lights", false);
		program.setTexture(normalTexture, "normal", true);

		program.injectIntoFragmentShader(
		"			
			vec4 normalLight( int lightsTextureID, int normalTextureID, float depth )
			{
				vec3 lightColor = vec3(1.0, 1.0, 1.0);
				vec3 ambientColor = vec3(0.0, 0.0, 0.0);
				vec3 falloff = vec3(0.4, 3.0, 20.0); // TODO: in depend of size!
				
				
				vec2 texRes = getTextureResolution(normalTextureID);
				
				// fetch pixel from normal-map
				vec4 normalTextureRGBZ = getTextureColor( normalTextureID, (vPos + (vTexCoord - 0.5)*vSize)/texRes );
				
				// flip x normal (depends on uv-map generation variants)
				//normalTextureRGBZ.r = 1.0 - normalTextureRGBZ.r;
				
				// vector to position of light
				vec3 light = vec3(  vTexCoord - 0.5 ,  normalTextureRGBZ.a - depth );
				
				float D = length(light);
				// calculate the light falloff
				//float attenuation = 1.0 / ( falloff.x + (falloff.y * D) + (falloff.z * D * D) );
				//float attenuation = clamp(1.0 - D * D / (0.5 * 0.5), 0.0, 1.0);
				float attenuation = max(1.0 - D * D / (0.25), 0.0);
				attenuation *= attenuation;

				//normalize our vectors
				vec3 N = normalize(normalTextureRGBZ.rgb * 2.0 - 1.0);
				//vec3 N = normalTextureRGBZ.rgb * 2.0 - 1.0; // normally should be already normalized by blender!
				vec3 L = normalize(light);
				
				//  dot product to determine diffuse by light and face-normal direction
				vec3 diffuse = lightColor * max( dot(N, L), 0.0);
	
				// add the final attenuated light to the ambientColor
				vec3 intensity = ambientColor + diffuse * attenuation;
	
				//return normalTextureRGBZ; // to test the normal-mapping
				return vec4(intensity, 1.0);
			}			
		");
		
		// instead of using normal "base" identifier to get the texture-color
		// the "_ID" postfix is to give access to use getTextureColor() manually 
		// from inside of the glsl blur() function to that texture-layer
		
		// blending to "add" multiple lights
		program.blendEnabled = true;
		program.blendSrc = BlendMode.ONE;
		program.blendDst = BlendMode.ONE;
		
		program.setColorFormula( "normalLight(lights_ID, normal_ID, depth)" ); // TODO: only need UV + Z here
		
		
		display.addProgram(program);
	}
	
	
	
	public function new(x:Int = 50, y:Int = 50, size:Int = 100)
	{
		this.x = x;
		this.y = y;
		this.size = size;
		buffer.addElement(this);
	}

	public function update()
	{
		buffer.updateElement(this);
	}

}
