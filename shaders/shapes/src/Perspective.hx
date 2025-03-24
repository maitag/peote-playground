package;

import lime.graphics.Image;
import utils.Loader;
import peote.view.*;

class Perspective implements Element
{
	// @posX public var x:Int;

	// tilt the tip:
	@custom @const @formula("(mouseX-0.5)*800.0") var tilt:Int;
	@posX @formula("x + tilt*(1.0-aPosition.y)") public var x:Int;

	@posY public var y:Int;
	
	@sizeY public var h:Int; // height

	// how much procent of fully width the tip of trapezoid have
	// @custom @varying public var tip:Float = 1.0;
	@custom @varying @const @formula("mouseY") var tip:Float = 1.0;
	
	@sizeX @formula("w - (w-(w*tip))*(1.0-aPosition.y)") public var w:Int; // width

	// REMAP the ORIGIN QUAD texture-COORDS:
	#if html5
	// dirty webgl-HACK to avoid "flat"
	@custom @varying @const @formula("0.0; webglTexCoordX = (aPosition.x * size.x - pivot.x)/aSize.x") var texCoordX:Float;
	#else
	@custom @varying @const @formula("(aPosition.x * size.x - pivot.x)/aSize.x") var texCoordX:Float;
	#end

	@pivotX @const @formula("w/2.0") var px:Int;
	@pivotY @const @formula("h/2.0") var py:Int;


	// @rotation @const @formula("rotation") var r:Float;

	
	static public var buffer:Buffer<Perspective>;
	static public var program:Program;

	// -----------------------------------------------
	
	static public function init(uniforms:Array<UniformFloat>, display:Display) {	
		buffer = new Buffer<Perspective>(1, 1, true);
		program = new Program(buffer);

		if (PeoteGL.Version.isES3) {
			program.injectIntoVertexShader("out float webglTexCoordX;", uniforms); // dirty webgl-HACK to avoid "flat"
		}
		else program.injectIntoVertexShader(uniforms);

		display.addProgram(program);
		
		// load grid test-image:
		Loader.image("assets/grid.png", true, function (image:Image) 
		{
			var texture = new Texture(image.width, image.height);
			texture.setSmooth(false,false);
			texture.setData(image);				
			program.setTexture(texture);
			
			program.injectIntoFragmentShader('
			${(PeoteGL.Version.isES3) ? "in float webglTexCoordX;" : ""} // dirty webgl-HACK

			vec4 transformTexture(int textureID, float texCoordX, float tip) {				
				
				// dirty webgl-HACK to avoid "flat"
				${(PeoteGL.Version.isES3) ? "
					return getTextureColor( textureID, vec2(0.5 + webglTexCoordX / mix(tip, 1.0, vTexCoord.y), vTexCoord.y ));
					" 
					: 
					"
					texCoordX = 0.5 + texCoordX / mix(tip, 1.0, vTexCoord.y);
					return getTextureColor( textureID, vec2(texCoordX, vTexCoord.y ));
					"
				} 
				
				
				

				// to let texture scale smaller on trapezoids tip
				// return getTextureColor( textureID, vec2(texCoordX, pow(vTexCoord.y,tip) ));
			}
			'
			// ,uniforms // TAKE CARE, on webgl sometimes the same uniform can not shared between vertex and fragment shader
			);
			program.setColorFormula("transformTexture(default_ID, texCoordX, tip)");

		});

	}	
	
	public function new(x:Int = 0, y:Int = 0, w:Int = 100, h:Int = 100, tip:Float = 0.5) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		// this.tip = tip;
		buffer.addElement(this);
	}
}
