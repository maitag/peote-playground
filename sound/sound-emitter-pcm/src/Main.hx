package;

import peote.view.Texture;
import peote.view.TextureFormat;
import format.wav.Data.WAVE;
import haxe.io.BytesInput;
import peote.view.TextureData;
import haxe.CallStack;
import haxe.io.Bytes;

import lime.app.Application;
import lime.ui.Window;
import lime.media.AudioSource;
import lime.media.AudioBuffer;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

import utils.Loader;

class Main extends Application {
	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	
	var peoteView:PeoteView;
	var buffer:Buffer<Emitter>;
	var display:Display;
	var program:Program;

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		display = new Display(0, 0, window.width, window.height, Color.BLACK);
		peoteView.addDisplay(display);

		buffer = new Buffer<Emitter>(4, 4, true);
		program = new Program(buffer);
		display.addProgram(program);

		loadSound();
	}

	// ------------------------------------------------------------

	 // all have samplingRate of 11025
	var soundWaveFiles:Array<String> = [
		'assets/sinus.wav',
		// 'assets/01.wav',
		// 'assets/02.wav',
		// 'assets/04.wav',
		// 'assets/05.wav',
		// 'assets/06.wav',
		// 'assets/09.wav',
	];

	// load multiple sound-waves
	function loadSound()
	{
		Loader.bytesArray( soundWaveFiles, false, // errorhandling/debug
			// --------------------- progress handler ---------------------
			function(index:Int, loaded:Int, size:Int) {
				trace(' $index progress ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
			},
			function(loaded:Int, size:Int) {
				trace(' Progress overall: ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
			},
			// --------------------- load handler ---------------------
			// function(index:Int, bytes:Bytes) {trace('$index loaded completely.');},
			createSoundSources
		);
	}

	// ------------------------------------------------------------

	var sources:Array<AudioSource> = [];

	function createSoundSources(bytesArray:Array<Bytes>)
	{
		trace(' --- all data loaded ---');	
		for (bytes in bytesArray) {			
			var buffer = AudioBuffer.fromBytes(bytes);
			sources.push(new AudioSource(buffer));
		}

		createTextureData(bytesArray);
	}

	// ------------------------------------------------------------

	function createTextureData(bytesArray:Array<Bytes>)
	{
		var textureData = new TextureData(128,128, TextureFormat.RG);

		for (bytes in bytesArray) {
			
			var wav:WAVE = new format.wav.Reader(new BytesInput(bytes)).read();
			trace(wav.data.length , wav.header);
			
			// converting functions
			inline function toInt16(v:Int):Int return (v > 32767 ? v - 65536 : v );
			inline function toByte(v:Int):Int return Std.int( Math.round( (v/32767 + 1)/2 * 255) );
			
			// set textureData pixels (channel 1 -> left, channel 2 -> green)
			var i:Int = 0;
			var x:Int = 0;
			var y:Int = 0;

			while (i < wav.data.length) {
				var left:Int = toInt16( wav.data.getUInt16(i) );
				i+=2;
				var right:Int = toInt16( wav.data.getUInt16(i) );
				i+=2;

				if (x < textureData.width) x++;
				else {x = 0; y++;}

				textureData.setRed(x, y, toByte(left) );
				textureData.setGreen(x, y, toByte(right) );

				// if (i<200) trace('left:$left <-> right: $right');
				if (i<200) trace('left:${toByte(left)} <-> right: ${toByte(right)}');
			}

			// little BREAK HERE to TEST ONLY the FIRST one
			break;
		}

		var texture:Texture = textureData.toTexture();
		program.setTexture(texture, true);

		#if html5
		window.onMouseDown.add((x, y, button) -> { window.onMouseDown.removeAll(); spawnEmitters(); }); // webbrowser needs an initial click!!!
		#else
		spawnEmitters();
		#end
	}

	
	function spawnEmitters()
	{
		// spawn only the one for testing at now:
		var bird = new Emitter(sources[0], window.height>>1, window.height>>1, window.height, window.height, Color.WHITE, Color.WHITE, 0.0);
		buffer.addElement(bird);
		peoteView.zoom = 6.0;

		/*
		for (source in sources) {
			var bird = new Emitter(source, randomise(16, window.width - 16 ), randomise(16, window.height - 16), 32, 32, Color.RED1, Color.random(), 0.9);
			buffer.addElement(bird);
			// bird.play();
			setGain(bird, bird.x, bird.y);
			buffer.update();


			// bird.playRepeated(0);
			bird.playRepeatedRND(0, 0);

		}
		*/

		window.onMouseMove.add(onMouseMoved);
	}

	function setGain(bird:Emitter, x:Float, y:Float){
		var distance = Math.sqrt((bird.x - x) * (bird.x - x) + (bird.y - y) * (bird.y - y));
		// todo : apply distance better
		bird.setGain(distance / window.width);
	}

	function randomise(min, max):Int {
		return Std.random(max - min + 1) + min;
	}


	// -------------- Interactive - Events -------------------

	function onMouseMoved(x:Float, y:Float) {
		for(i in 0...buffer.length){
			var bird = buffer.getElement(i);
			setGain(bird, x, y);
		}
		buffer.update();
	}

	




	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// access embeded assets from here
	// override function onPreloadComplete():Void {}

	// for game-logic update
	// override function update(deltaTime:Int):Void {}

	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");		

	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseMove (x:Float, y:Float):Void {}	
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}	
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	// override function onWindowLeave():Void { trace("onWindowLeave"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
	
}
