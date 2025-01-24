package;

import lime.graphics.Image;
import utils.Loader;
import peote.view.*;

class Fanblade implements Element
{
	@posX public var x:Int;
	@posY public var y:Int;
	
	@sizeX public var w:Int;

	@custom public var hLeft:Int;
	@sizeY @formula("hRight - (hRight-hLeft) * (1.0-aPosition.x)") public var hRight:Int;

	// REMAP the ORIGIN QUAD texture-COORDS:
	@custom @varying @const @formula("(aPosition.y * size.y - pivot.y)/aSize.y") var texCoordY:Float;

	@pivotX public var px:Int = 0;
	@pivotY @const @formula("hRight/2.0") var py:Int;
	
	@rotation @formula("r + rotation") public var r:Float = 0.0;
	static public var buffer:Buffer<Fanblade>;
	static public var program:Program;

	// -----------------------------------------------
	
	static public function init(uniforms:Array<UniformFloat>, display:Display) {	
		buffer = new Buffer<Fanblade>(1, 1, true);
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
			vec4 transformTexture(int textureID, float texCoordY) {				
				// texCoordY = 1.0 / mix(0.25, 1.0, vTexCoord.x) * texCoordY + 0.5 ;
				// texCoordY = 0.5 + texCoordY / (0.25 + (1.0 - 0.25)* vTexCoord.x);
				
				texCoordY = 0.5 + texCoordY / mix(0.25, 1.0, vTexCoord.x);
				
				return getTextureColor( textureID, vec2(vTexCoord.x, texCoordY ));
			}
			");
			program.setColorFormula("transformTexture(default_ID, texCoordY)");

		});

	}	
	
	public function new(x:Int = 0, y:Int = 0, w:Int = 100, hLeft:Int = 50, hRight:Int = 100, px:Int = 0, rotation:Float = 0) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.hLeft = hLeft;
		this.hRight = hRight;
		this.px = px;
		this.r = rotation * 180/Math.PI;
		buffer.addElement(this);
	}
}
