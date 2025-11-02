package perspective;

import lime.graphics.Image;
import peote.view.*;

class PerspectiveXY implements Element {
	
	// how much procent the tip of trapezoid have
	@custom @varying @formula("tipX") var tipX:Float = 0.5;
	@custom @varying @formula("tipY") var tipY:Float = 1.0;

	// tilt the tip:
	@custom @const @formula("(tipX-0.5)*w") var tiltX:Float;
	@custom @const @formula("(tipY-0.5)*h") var tiltY:Float;

	// position
	@posX @formula("x + tiltX*(1.0-aPosition.y)") public var x:Float;
	@posY @formula("y + tiltY*(1.0-aPosition.x)") public var y:Float;

	// size
	@sizeX @formula("w - (w-(w*tipY))*(1.0-aPosition.y)") public var w:Float; // width
	@sizeY @formula("h - (h-(h*tipX))*(1.0-aPosition.x)") public var h:Float; // height

	@color public var tint:Color = 0xffffffFF;

	@pivotX @const @formula("w/2.0") var px:Float;
	@pivotY @const @formula("h/2.0") var py:Float;

	// REMAP the ORIGIN QUAD texture-COORDS:
	#if html5
	// dirty webgl-HACK to avoid "flat"
	@custom @varying @const @formula("0.0; webglTexCoordX = (aPosition.x * size.x - pivot.x)/aSize.x") var texCoordX:Float;
	@custom @varying @const @formula("0.0; webglTexCoordY = (aPosition.y * size.y - pivot.y)/aSize.y") var texCoordY:Float;
	#else
	@custom @varying @const @formula("(aPosition.x * size.x - pivot.x)/aSize.x") var texCoordX:Float;
	@custom @varying @const @formula("(aPosition.y * size.y - pivot.y)/aSize.y") var texCoordY:Float;
	#end

	static public var buffer:Buffer<PerspectiveXY>;
	static public var program:Program;

	// -----------------------------------------------

	static public function init(display:Display, bufferSize:Int) {
		buffer = new Buffer<PerspectiveXY>(bufferSize, true);
		program = new Program(buffer);

		if (PeoteGL.Version.isES3) {
			program.injectIntoVertexShader("out float webglTexCoordX;"); // dirty webgl-HACK to avoid "flat"
			program.injectIntoVertexShader("out float webglTexCoordY;");
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

			vec4 transformTexture(int textureID, float texCoordX, float texCoordY, float tipX, float tipY) {				
				
				// dirty webgl-HACK to avoid "flat"
				float tx = ${(PeoteGL.Version.isES3) ? "webglTexCoordX" :"texCoordX"};
				float ty = ${(PeoteGL.Version.isES3) ? "webglTexCoordY" :"texCoordY"};
				
				tx = 0.5 + tx / mix(tipY, 1.0, vTexCoord.y);
				ty = 0.5 + ty / mix(tipX, 1.0, vTexCoord.x);
				
				return getTextureColor( textureID, vec2(tx, ty ));

				// to let texture scale smaller on trapezoids tip
				// return getTextureColor( textureID, vec2(texCoordX, pow(vTexCoord.y,tip) ));
			}
			' // ,uniforms // TAKE CARE, on webgl sometimes the same uniform can not shared between vertex and fragment shader
			);
			program.setColorFormula("vec4(transformTexture(default_ID, texCoordX, texCoordY, tipX, tipY).rgb, tint.a)");
		});
	}


	// ------------ constructor --------------

	public function new(x:Float, y:Float, w:Float, h:Float, tipX:Float, tipY:Float) {
		set(x, y, w, h, tipX, tipY);
		buffer.addElement(this);
	}

	public function set(x:Float, y:Float, w:Float, h:Float, tipX:Float, tipY:Float) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.tipX = tipX;
		this.tipY = tipY;
	}
	
	public function update() {
		buffer.updateElement(this);
	}

}
