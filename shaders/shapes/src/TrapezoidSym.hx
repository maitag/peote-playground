package;

import lime.graphics.Image;
import peote.view.*;

class TrapezoidSym implements Element
{
	@posX public var x:Int;
	@posY public var y:Int;
	
	@sizeX public var w:Int;
	@sizeY public var h:Int;

	@pivotX public var px:Int = 0;
	@pivotY public var py:Int = 0;
	@rotation public var r:Float = 0.0;

	static public var buffer:Buffer<TrapezoidSym>;
	static public var program:Program;

	// -----------------------------------------------
	
	static public function init(uniforms:Array<UniformFloat>, display:Display) {	
		buffer = new Buffer<TrapezoidSym>(1, 1, true);
		program = new Program(buffer);		
		
		display.addProgram(program);
		
		// load grid test-image:
		Load.image("assets/grid.png", true, function (image:Image) 
		{
			var texture = new Texture(image.width, image.height);
			texture.setSmooth(true,true);
			texture.setData(image);				
			program.setTexture(texture);

			program.injectIntoFragmentShader("
			
			float dot2(in vec2 v ) { return dot(v,v); }

			float trapezoid( in vec2 p, in float r1, float r2, float he )
			{
				p.x = p.x * 2.0 - 1.0;
				p.y = p.y * 2.0 - 1.0;
				
				
				vec2 k1 = vec2(r2,he);
				vec2 k2 = vec2(r2-r1,2.0*he);

				p.x = abs(p.x);
				vec2 ca = vec2(max(0.0,p.x-((p.y<0.0)?r1:r2)), abs(p.y)-he);
				vec2 cb = p - k1 + k2*clamp( dot(k1-p,k2)/dot2(k2), 0.0, 1.0 );
				
				float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
				
				return s*sqrt( min(dot2(ca),dot2(cb)) );
			}

			vec4 transformTexture(int textureID) {

				// return getTextureColor( textureID, vec2(vTexCoord.x, mix((vTexCoord.y+vTexCoord.x*0.5)*0.5, vTexCoord.y, vTexCoord.x)  ));
				float d = trapezoid(vTexCoord, 0.8, 0.2, 1.0);
				return vec4( (d<0.0) ? 1.0+d*2.0 : 0.0 , 0.0, 0.0, 1.0);


				// TODO: try this for mapping: https://www.shadertoy.com/view/wlc3Rj

			}
			", uniforms);
			program.setColorFormula("transformTexture(default_ID)");

		});

	}	
	
	public function new(x:Int = 0, y:Int = 0, w:Int = 100, h:Int = 100, px:Int = 0, py:Int = 0, r:Float = 0) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.px = px;
		this.py = py;
		this.r = r;
		buffer.addElement(this);
	}
}
