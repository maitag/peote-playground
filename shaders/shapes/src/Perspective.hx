package;

import lime.graphics.Image;
import peote.view.*;

class Perspective implements Element {
	// @posX public var x:Int;
	@custom @varying public var tipX:Float = 0.5;
	@custom @varying public var tipY:Float = 1.0;
	@rotation @varying public var rotation:Float = 0.0;

	// tilt the tip:
	@custom @const @formula("(tipX-0.5)*w") var tilt:Int;

	@posX @formula("x + tilt*(1.0-aPosition.y)") public var x:Int;

	@posY public var y:Int;
	
	@sizeY public var h:Int; // height

	// how much procent of fully width the tip of trapezoid have
	// @custom @varying public var tip:Float = 1.0;
	@custom @varying @const @formula("tipY") var tip:Float = 1.0;

	@sizeX @formula("w - (w-(w*tip))*(1.0-aPosition.y)") public var w:Int; // width

	@color public var tint:Color = 0xffffffFF;

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

	static public function init(display:Display, bufferSize:Int) {
		buffer = new Buffer<Perspective>(bufferSize, true);
		program = new Program(buffer);

		if (PeoteGL.Version.isES3) {
			program.injectIntoVertexShader("out float webglTexCoordX;"); // dirty webgl-HACK to avoid "flat"
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
			${(PeoteGL.Version.isES3) ? "in float webglTexCoordX;" : ""} // dirty webgl-HACK

			vec4 transformTexture(int textureID, float texCoordX, float tip) {				
				
				// dirty webgl-HACK to avoid "flat"
				${(PeoteGL.Version.isES3) ? "
					return getTextureColor( textureID, vec2(0.5 + webglTexCoordX / mix(tip, 1.0, vTexCoord.y), vTexCoord.y ));
					" : "
					texCoordX = 0.5 + texCoordX / mix(tip, 1.0, vTexCoord.y);
					return getTextureColor( textureID, vec2(texCoordX, vTexCoord.y ));
					"} 
				
				
				

				// to let texture scale smaller on trapezoids tip
				// return getTextureColor( textureID, vec2(texCoordX, pow(vTexCoord.y,tip) ));
			}
			' // ,uniforms // TAKE CARE, on webgl sometimes the same uniform can not shared between vertex and fragment shader
			);
			program.setColorFormula("vec4(transformTexture(default_ID, texCoordX, tip).rgb, tint.a)");
		});
	}

	public function draw(x:Float, y:Float, width:Float, height:Float, rotation:Float, tipX:Float, tipY:Float) {
		this.x = Math.ceil(x);
		this.y = Math.ceil(y);
		w = Math.ceil(width);
		h = Math.ceil(height);
		this.rotation = rotation;
		this.tipX = tipX;
		this.tipY = tipY;
		buffer.updateElement(this);
		trace('tip x ${this.tipX} y ${this.tipY} ');
	}

	public function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0) {
		this.x = Math.ceil(x);
		this.y = Math.ceil(y);
		this.w = Math.ceil(w);
		this.h = Math.ceil(h);
		buffer.addElement(this);
	}
}
