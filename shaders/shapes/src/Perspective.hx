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
	@custom @varying @const @formula("(aPosition.x * size.x - pivot.x)/aSize.x") var texCoordX:Float;

	@pivotX @const @formula("w/2.0") var px:Int;
	@pivotY @const @formula("h/2.0") var py:Int;
	
	static public var buffer:Buffer<Perspective>;
	static public var program:Program;

	// -----------------------------------------------
	
	static public function init(uniforms:Array<UniformFloat>, display:Display) {	
		buffer = new Buffer<Perspective>(1, 1, true);
		program = new Program(buffer);		
		program.injectIntoVertexShader(uniforms);
		display.addProgram(program);
		
		// load grid test-image:
		Loader.image("assets/grid.png", true, function (image:Image) 
		{
			var texture = new Texture(image.width, image.height);
			texture.setSmooth(true,true);
			texture.setData(image);				
			program.setTexture(texture);

			program.injectIntoFragmentShader("
			vec4 transformTexture(int textureID, float texCoordX, float tip) {				
				
				texCoordX = 0.5 + texCoordX / mix(tip, 1.0, vTexCoord.y);
				
				return getTextureColor( textureID, vec2(texCoordX, vTexCoord.y ));

				// to let texture scale smaller on trapezoids tip
				// return getTextureColor( textureID, vec2(texCoordX, pow(vTexCoord.y,tip) ));
			}
			", uniforms);
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
