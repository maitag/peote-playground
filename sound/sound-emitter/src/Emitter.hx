package;

import lime.media.AudioSource;
import lime.media.AudioBuffer;

import peote.view.Element;
import peote.view.Color;

class Emitter implements Element
{
	@posX public var x:Int;
	@posY public var y:Int;
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	// hardcode the pivot into the middle 
	@pivotX @const @formula("w/2.0") var _px:Float;
	@pivotY @const @formula("h/2.0") var _py:Float;
	
	@color public var c:Color;

	// ----------------------------------------------------------------------	
	public var volume:Float; // sound volume (from 0.0 to 1.0)
	public var colorQuite:Color; // color at the quietest volume
	public var colorLoud:Color; // color at the loudest volume

	public var source:AudioSource;

	// ----------------------------------------------------------------------
	// ----------------------------------------------------------------------
	// ----------------------------------------------------------------------

	public function new(source:AudioSource, x:Int, y:Int, w:Int, h:Int, colorQuite:Color, colorLoud:Color, volume:Float )
	{
		this.source = source;
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.colorQuite = colorQuite;
		this.colorLoud = colorLoud;
		setVolume(volume);
	}

	// make the color in depend of volume
	public function setVolume(volume:Float) {
		this.volume = volume;
		c = Color.FloatRGBA( 
			colorQuite.rF + (colorLoud.rF - colorQuite.rF)*volume,
			colorQuite.gF + (colorLoud.gF - colorQuite.gF)*volume,
			colorQuite.bF + (colorLoud.bF - colorQuite.bF)*volume,
			colorQuite.aF + (colorLoud.aF - colorQuite.aF)*volume
		);
		source.gain = volume;
	}

	public function play() {
		source.play();
	}
	/*
	public function playRepeated(waitAfterPlay:Int) {
		play();
		var timer = new haxe.Timer(source.length + waitAfterPlay); // all into MILLI-SECONDS 4sure ;)
		timer.run = () -> play();		
	}
	*/

	var multiplicator:Int = 0;
	public function playRepeated(waitAfterPlay:Int=0, randomOffset:Int=0) { // all into MILLI-SECONDS 4sure ;)
		play();
		var timer = new haxe.Timer(source.length + waitAfterPlay - randomOffset);
		timer.run = () -> {
			var r:Int = Std.random(randomOffset * 2) + multiplicator++ * randomOffset * 2;
			haxe.Timer.delay( ()->play(), r );
		}
	}

}
