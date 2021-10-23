package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Texture;

class Shaking implements Element
{
	// at what peote.time it have to shake
	@custom public var shakeAtTime:Float = -100.0;
	
	// params for shake: number of shakes, size in pixel, durationtime in seconds
	@posX @formula("x + shake(shakeAtTime, 7.0, 8.0, 1.2)") public var x:Int; 
	@posY @formula("y + shake(shakeAtTime, 5.0, 6.0, 0.9)") public var y:Int;
	
	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	// --------------------------------------------------------------------------
	
	static public var buffer:Buffer<Shaking>;
	static public var program:Program;

	
	
	static public function init(display:Display, texture:Texture)
	{	
		buffer = new Buffer<Shaking>(1, 1, true);
		program = new Program(buffer);
		
		program.setTexture(texture, "custom", false);
		
		program.injectIntoVertexShader(
		"
			#define TWO_PI 6.28318530718
			float shake( float atTime, float freq, float size, float duration )
			{
				float t = max(0.0, uTime - atTime);				
				t = (clamp(t, 0.0, duration) / duration);			
				return 1.0 - size + size * sin(freq * TWO_PI * t) * (t+0.5)*t*t*(t-1.0)*(t-1.0)*15.5;
			}
			
		"
		, true // allways include uTime
		);
		
		display.addProgram(program);
	}
	
		
	public function new(x:Int = 0, y:Int = 0, w:Int = 100, h:Int = 100) 
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		buffer.addElement(this);
	}
	
	public function shake(atTime:Float) {
		shakeAtTime = atTime;
		buffer.updateElement(this);
	}

}
