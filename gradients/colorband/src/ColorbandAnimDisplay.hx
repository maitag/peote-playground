package;

import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

import peote.view.Element;

// ------------ peote view Element -------------------

class HGradientAnim implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX @anim("pingpong") public var x:Int=0;
	@posY public var y:Int=0;
	
	// size in pixel
	@sizeX @anim() public var w:Int=800;
	@sizeY public var h:Int=600;
		
	// colors (RGBA)
	@color @anim() public var colorStart:Color = 0x000000ff;
	@color @anim() public var colorEnd  :Color = 0xffffffff;
	
	// interpolations from 0.0 (smooth) to 1.0 (linear)
	@custom @varying @anim() public var interpolateStart:Float = 0.0;
	@custom @varying @anim() public var interpolateEnd  :Float = 0.0;
	
	// this is injected by program of ColorbandDisplay
	public static var fShader =
	"
		vec4 gradient(vec4 c0, vec4 c1, float s0, float s1)
		{
			float x = vTexCoord.x; // horizontally
			
			// semmis interpolation
			float m = mix( 
				mix( smoothstep(0.0     , 1.0 + s1, x), x, s0 ),
				mix( smoothstep(0.0 - s0, 1.0     , x), x, s1 ),
				x 
			);
			
			return mix( c0, c1, m);
		}			
	";

	var DEFAULT_COLOR_FORMULA = "gradient(colorStart, colorEnd, interpolateStart, interpolateEnd)";	
	//var OPTIONS = { alpha:true };

	// interpolation here into API is from 0.0 (linear) to 1.0 (smooth)
	public function new(timeStart:Float, timeDuration:Float, x0:Int, x1:Int, y:Int, w0:Int, w1:Int, h:Int, colorStart0:Color, colorStart1:Color, colorEnd0:Color, colorEnd1:Color, interpolateStart0:Float, interpolateStart1:Float, interpolateEnd0:Float, interpolateEnd1:Float) {
		this.xStart = x0;
		this.xEnd = x1;
		this.y = y;
		this.wStart = w0;
		this.wEnd = w1;
		this.h = h;
		this.colorStartStart = colorStart0;
		this.colorStartEnd = colorStart1;
		this.colorEndStart = colorEnd0;
		this.colorEndEnd = colorEnd1;
		this.interpolateStartStart = 1.0 - Math.max(0.0, Math.min(1.0, interpolateStart0));
		this.interpolateStartEnd = 1.0 - Math.max(0.0, Math.min(1.0, interpolateStart1));
		this.interpolateEndStart = 1.0 - Math.max(0.0, Math.min(1.0, interpolateEnd0));
		this.interpolateEndEnd = 1.0 - Math.max(0.0, Math.min(1.0, interpolateEnd1));
		this.timeStart = timeStart;
		this.timeDuration = timeDuration;
	}
}

// ------------ peote view Display -------------------

class ColorbandAnimDisplay extends Display 
{

	var program:Program;
	var buffer:Buffer<HGradientAnim>;
	
	public function new(x:Int, y:Int, width:Int, height:Int, bgColor:Color = 0) 
	{
		super(x, y, width, height, bgColor);
		
		buffer = new Buffer<HGradientAnim>(0xffff, 8192, true);
		
		program = new Program(buffer);
		program.injectIntoFragmentShader(HGradientAnim.fShader);
		
		this.addProgram(program);
	}
	
	// TODO: adding another param for scale up to display-size
	public function create(colorbandFrom:Colorband, colorbandTo:Colorband, timeStart:Float, timeDuration:Float, y:Int, height:Int, defaultSize:Int = 32, defaultInterpolate:Interpolate = null )
	{
		if (defaultInterpolate == null) defaultInterpolate = Interpolate.SMOOTH;
		
		var xFrom:Int = 0;
		var xTo:Int = 0;
		
		if (colorbandFrom.length != colorbandTo.length) throw("both colorbands have to be same into length to animate from -> to");
		
		for (i in 0...colorbandFrom.length) {
			
			var cFrom = colorbandFrom[i];
			var cTo = colorbandTo[i];
			
			var sizeFrom:Int = (cFrom.size == null) ? defaultSize : cFrom.size;				
			var sizeTo:Int = (cTo.size == null) ? defaultSize : cTo.size;			
			
			var interpolate:Interpolate;
			
			interpolate = (cFrom.interpolate == null) ? defaultInterpolate : cFrom.interpolate;
			var interpolateFromStart:Float = (interpolate.start == null) ? defaultInterpolate.start : interpolate.start;
			var interpolateFromEnd:Float = (interpolate.start == null) ? defaultInterpolate.start : interpolate.end;
			
			interpolate = (cTo.interpolate == null) ? defaultInterpolate : cTo.interpolate;				
			var interpolateToStart:Float = (interpolate.start == null) ? defaultInterpolate.start : interpolate.start;
			var interpolateToEnd:Float = (interpolate.start == null) ? defaultInterpolate.start : interpolate.end;
			
			buffer.addElement( 
				new HGradientAnim( timeStart, timeDuration, 
					xFrom, xTo,
					y,
					sizeFrom, sizeTo,
					height,
					cFrom.color, cTo.color,
					(i < colorbandFrom.length - 1) ? colorbandFrom[i + 1].color : colorbandFrom[i].color,
					(i < colorbandFrom.length - 1) ? colorbandTo[i + 1].color : colorbandTo[i].color,
					interpolateFromStart, interpolateFromEnd,
					interpolateToStart, interpolateToEnd
				) 
			);
			
			xFrom += sizeFrom;
			xTo += sizeTo;
			
		}
	}
	
	
}