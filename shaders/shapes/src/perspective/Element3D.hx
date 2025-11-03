package perspective;

import lime.graphics.Image;
import peote.view.*;

class Element3D implements Element {
	
	// how much procent the tip of trapezoid have
	@custom @varying @formula("tipX") public var tipX:Float = 0.0; // goes from -1 to +1 now
	@custom @varying @formula("tipY") public var tipY:Float = 0.0;
	
	// procentual diff of opposite side-lengths (like FieldOfView)
	@custom @varying var FOV:Float = 0.4;


	// tilt at the tip:
	/*@custom @formula("(tiltX-0.5)*w") public var tiltX:Float = 0.5;
	@custom @formula("(tiltY-0.5)*h") public var tiltY:Float = 0.5;
	@posX @formula("x + tiltX*(0.5-aPosition.y)") public var x:Float;
	@posY @formula("y + tiltY*(0.5-aPosition.x)") public var y:Float;
	*/

	// position
	@posX @formula("x") public var x:Float;
	@posY @formula("y") public var y:Float;

	// size
	@sizeX @formula("w + tipX*w*FOV*aPosition.y") public var w:Float; // width
	@sizeY @formula("h + tipY*h*FOV*aPosition.x") public var h:Float; // height

	@color public var tint:Color = 0xffffffFF;

	// pivot
	@pivotX @formula("w*px") public var px:Float=0.5;
	@pivotY @formula("h*py") public var py:Float=0.5;

	// REMAP the ORIGIN QUAD texture-COORDS:
	#if html5
	// dirty webgl-HACK to avoid "flat"
	@custom @varying @const @formula("0.0; webglTexCoordX = (aPosition.x * size.x - w/2.0)/aSize.x") var texCoordX:Float;
	@custom @varying @const @formula("0.0; webglTexCoordY = (aPosition.y * size.y - h/2.0)/aSize.y") var texCoordY:Float;
	#else
	@custom @varying @const @formula("(aPosition.x * size.x - w/2.0)/aSize.x") var texCoordX:Float;
	@custom @varying @const @formula("(aPosition.y * size.y - h/2.0)/aSize.y") var texCoordY:Float;
	// @custom @varying @const @formula("(aPosition.x * size.x - pivot.x)/aSize.x") var texCoordX:Float;
	// @custom @varying @const @formula("(aPosition.y * size.y - pivot.y)/aSize.y") var texCoordY:Float;
	#end

	// rotation
	@rotation public var r:Float = 0.0;

	static public var buffer:Buffer<Element3D>;
	static public var program:Program;

	// -----------------------------------------------

	static public function init(display:Display, bufferSize:Int) {
		buffer = new Buffer<Element3D>(bufferSize, true);
		program = new Program(buffer);

		if (PeoteGL.Version.isES3) {
			program.injectIntoVertexShader("out float webglTexCoordX; out float webglTexCoordY;"); // dirty webgl-HACK to avoid "flat"
		}

		program.blendEnabled = true;
		display.addProgram(program);
		
		// load grid test-image:
		Load.image("assets/grid.png", true, function(image:Image) {
			var texture = new Texture(image.width, image.height);
			texture.setSmooth(false, false);
			texture.setData(image);
			program.setTexture(texture);
			
			program.injectIntoFragmentShader('
			${(PeoteGL.Version.isES3) ? "in float webglTexCoordX;in float webglTexCoordY;" : ""} // dirty webgl-HACK to avoid "flat"

			vec4 transformTexture(int textureID, float texCoordX, float texCoordY, float tipX, float tipY, float FOV) {				
				
				// dirty webgl-HACK to avoid "flat"
				float tx = ${(PeoteGL.Version.isES3) ? "webglTexCoordX" : "texCoordX"};
				float ty = ${(PeoteGL.Version.isES3) ? "webglTexCoordY" : "texCoordY"};
				
				// tx = 0.5 + tx / mix(1.0 ,1.0 + tipX*FOV, vTexCoord.y);
				// ty = 0.5 + ty / mix(1.0 ,1.0 + tipY*FOV, vTexCoord.x);
				tx = 0.5 + tx / (1.0 + tipX*FOV * vTexCoord.y);
				ty = 0.5 + ty / (1.0 + tipY*FOV * vTexCoord.x);
				
				// return getTextureColor( textureID, vec2(tx, ty ));

				// to let texture scale smaller on trapezoids tip
				return getTextureColor( textureID, vec2( pow(tx, 1.0 - tipY*FOV), pow(ty, 1.0 - tipX*FOV) ));
			}
			' // ,uniforms // TAKE CARE, on webgl sometimes the same uniform can not shared between vertex and fragment shader
			);
			program.setColorFormula("vec4(transformTexture(default_ID, texCoordX, texCoordY, tipX, tipY, FOV).rgb, tint.a)");
		});
	}


	// ------------ constructor --------------

	public function new(x:Float, y:Float, w:Float, h:Float) {
		set(x, y, w, h);
		buffer.addElement(this);
	}

	public function set(x:Float, y:Float, w:Float, h:Float) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}
	
	public function update() {
		buffer.updateElement(this);
	}

}
