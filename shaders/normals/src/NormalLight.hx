package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Texture;

class NormalLight implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@varying @posX public var x:Int = 50;
	@varying @posY public var y:Int = 50;
	
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
			vec4 normalLight( int lightsTextureID, int normalTextureID )
			{
				float lightZ = 0.5;
				vec3 lightColor = vec3(1.0, 1.0, 1.0);
				vec3 ambientColor = vec3(0.3, 0.3, 0.3);
				vec3 falloff = vec3(0.4, 2.0, 5.0); // TODO
				
				
				vec2 texRes = getTextureResolution(lightsTextureID);
				
				vec4 normalTextureRGBZ = getTextureColor( normalTextureID, (vPos + (vTexCoord - 0.5)*vSize)/texRes );  // TODO
				
				// vector to position of light
				// TODO: diff to z from normalTextureRGBZ.a
				vec3 light = vec3(  ( vTexCoord - vec2(0.5, 0.5)  )     ,   lightZ ) * vSize.x;
				
				float D = length(light);
				// calculate the light falloff -> TODO!!!
				float attenuation = 1.0;// / ( falloff.x + (falloff.y * D) + (falloff.z * D * D) );
				
				//normalize our vectors
				vec3 N = normalize(normalTextureRGBZ.rgb * 2.0 - 1.0);
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
		
		program.setColorFormula( "normalLight(lights_ID, normal_ID)" ); // TODO: only need UV + Z here
		
		
		display.addProgram(program);
	}
	
	
	
	public function new(x:Int = 50, y:Int = 50, size:Int = 100)
	{
		this.x = x;
		this.y = y;
		this.size = size;
		buffer.addElement(this);
	}

	public function update(x:Int, y:Int, ?size:Null<Int>)
	{
		this.x = x;
		this.y = y;
		if (size != null) this.size = size;
		buffer.updateElement(this);
	}

}
