package;

import peote.view.intern.Util;
import lime.media.AudioSource;
// import lime.media.AudioBuffer;

import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Texture;
import peote.view.Element;
import peote.view.Color;

class SoundBar implements Element
{
	@posX public var x:Int;
	@posY public var y:Int;
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	// hardcode the pivot into the middle 
	@pivotX @const @formula("w/2.0") var _px:Float;
	@pivotY @const @formula("h/2.0") var _py:Float;
	
	@color public var c:Color;

	// at what position into the wavTexture the wave data starts and how the length is
	// the line into texture what contains the wave
	@varying @custom public var wavStart:Float = 0.0;
	@varying @custom public var wavLength:Float = 1.0;
	@varying @custom public var timeStart:Float = -10.0;

	// ----------------------------------------------------------------------
	public static var buffer(default, null):Buffer<SoundBar>;
	public static var program(default, null):Program;

	public static function init(display:Display, wavTexture:Texture) {
		buffer = new Buffer<SoundBar>(16, 32);
		program = new Program(buffer);

		program.setTexture(wavTexture, "wavTexture", false);

		var deltaTime:String = Util.toFloatString(0.1);

		program.injectIntoFragmentShader(
		'	
			vec2 posToTexCoord(float pos, float wavStart, float wavLength) {
				pos = clamp(pos, 0.0, wavLength);
				float x = fract(wavStart + pos);
				float y = floor(wavStart + pos) / ${wavTexture.slotHeight}.0;
				return vec2(x , y);
			}

			vec4 soundBarVisualize( int textureID, float timeStart, float wavStart, float wavLength )
			{	
				float currentTime = uTime - timeStart;
				currentTime += mix( - $deltaTime, $deltaTime, vTexCoord.x);
				
				float currentPos = 11025.0 / ${wavTexture.slotWidth}.0 * currentTime;

				// little hack if pos is not into range (clamp into posToTexCoord only put it to start/end!) 
				if (currentPos < 0.0 || currentPos > wavLength) return vec4(0.0, 0.0, 0.0, 1.0);
								
				float peak = getTextureColor( textureID, posToTexCoord(currentPos, wavStart, wavLength) ).r;
				
				float intensity = 0.0;

				// soundWAVE:
				// if (vTexCoord.y < peak && vTexCoord.y > peak-0.01 ) intensity = 1.0;

				// soundBARs:
				if ( abs(0.5 - vTexCoord.y) < abs(0.5-peak) ) intensity = 1.0;

				return vec4(intensity, 0.0, 0.0, 1.0);

				// to test how the whole wavTexture is look like:
				// return getTextureColor( textureID, vec2 (vTexCoord.x, vTexCoord.y) );
			}			
		', true);

		program.setColorFormula( "soundBarVisualize(wavTexture_ID, timeStart, wavStart, wavLength)" );
	
		display.addProgram(program);
	}

	// ----------------------------------------------------------------------	
	public var gain:Float; // sound gain (from 0.0 to 1.0)
	public var colorQuite:Color; // color at the quietest gain
	public var colorLoud:Color; // color at the loudest gain
	public var source:AudioSource;

	// ----------------------------------------------------------------------
	// ----------------------------------------------------------------------
	// ----------------------------------------------------------------------
	public function new(source:AudioSource, wavStart:Float, wavLength:Float, x:Int, y:Int, w:Int, h:Int, colorQuite:Color, colorLoud:Color, gain:Float, timeStart:Float = 0.0 )
	{
		// trace(wavStart, wavLength);
		this.wavStart = wavStart;
		this.wavLength = wavLength;
		this.timeStart = timeStart;

		this.source = source;
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.colorQuite = colorQuite;
		this.colorLoud = colorLoud;
		setGain(gain);
		buffer.addElement(this);
	}

	// make the color in depend of gain
	public function setGain(gain:Float) {
		this.gain = gain;
		c = Color.FloatRGBA( 
			colorQuite.rF + (colorLoud.rF - colorQuite.rF)*gain,
			colorQuite.gF + (colorLoud.gF - colorQuite.gF)*gain,
			colorQuite.bF + (colorLoud.bF - colorQuite.bF)*gain,
			colorQuite.aF + (colorLoud.aF - colorQuite.aF)*gain,
		);
		source.gain = gain;
	}

	public function play() {
		source.play();
	}
	
	public function playRepeated(waitAfterPlay:Int) {
		play();
		// not good into sync to sound-length after a while, so maybe better onUpdate or by onComplete here!
		var timer = new haxe.Timer(source.length + waitAfterPlay);
		timer.run = () -> play();		
	}
	

	var multiplicator:Int = 0;
	public function playRepeatedRND(waitAfterPlay:Int=0, randomOffset:Int=0) { // all into MILLI-SECONDS 4sure ;)
		// trace(source.length);
		play();
		var timer = new haxe.Timer(source.length + waitAfterPlay - randomOffset);
		timer.run = () -> {
			var r:Int = Std.random(randomOffset * 2) + multiplicator * randomOffset * 2;
			multiplicator++;
			haxe.Timer.delay( ()->play(), r );
		}
	}

}
