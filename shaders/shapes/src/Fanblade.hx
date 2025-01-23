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

	// @custom @varying @const @formula("aPosition.y * size.y/aSize.y") var texCoordY:Float;
	// @custom @varying @const @formula("aPosition.y * size.y/aShort0") var texCoordY:Float;
	// @custom @varying @const @formula("(aPosition.y * size.y - pivot.y)/(aShort0)+0.5") var texCoordY:Float;
	// @custom @varying @const @formula("(aPosition.y * size.y - pivot.y)/(aSize.y)+0.5") var texCoordY:Float;
	@custom @varying @const @formula("(aPosition.y * size.y - pivot.y)/(aShort0)+0.5") var texCoordY1:Float;
	@custom @varying @const @formula("(aPosition.y * size.y - pivot.y)/(aSize.y)+0.5") var texCoordY2:Float;

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
			vec4 transformTexture(int textureID, float texCoordY1, float texCoordY2) {

				// return getTextureColor( textureID, vec2(vTexCoord.x, vTexCoord.y) );
				// return getTextureColor( textureID, vec2(vTexCoord.x, texCoordY1 ));
				// return getTextureColor( textureID, vec2(vTexCoord.x, texCoordY2 ));

				// This did not work exactly cos of triangulation and texcoords
				return getTextureColor( textureID, vec2(vTexCoord.x, mix(texCoordY1, texCoordY2, vTexCoord.x) ));
				

				// TODO: try to check upper and lower triangle separate!
				// return vec4(0.0, 0.0, sin(vTexCoord.x*100.0)*0.5+0.5, 1.0);
				// return vec4(0.0, 0.0, sin(vTexCoord.y*100.0)*0.5+0.5, 1.0);
				// return vec4(0.0, 0.0, sin(texCoordY2*100.0)*0.5+0.5, 1.0);
				// return vec4(0.0, 0.0, texCoordY2, 1.0);
			}
			");
			program.setColorFormula("transformTexture(default_ID, texCoordY1, texCoordY2)");

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
