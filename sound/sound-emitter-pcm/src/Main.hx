package;

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
	var sources:Array<AudioSource>;
	var isSourcesReady:Bool = false;
	var textureDatas:Array<TextureData>;

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
	
	public var peoteView:PeoteView;
	public var buffer:Buffer<Emitter>;
	public var display:Display;
	public var program:Program;

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		display = new Display(10, 10, window.width - 20, window.height - 20, Color.BLACK);
		peoteView.addDisplay(display);

		buffer = new Buffer<Emitter>(4, 4, true);
		program = new Program(buffer);
		display.addProgram(program);

		loadSound();
	}

	// load multiple sound-waves
	public function loadSound() {
		var fileType = "wav";

		Loader.bytesArray([
				'assets/01' + '.$fileType',
				'assets/02' + '.$fileType',
				'assets/04' + '.$fileType',
				'assets/05' + '.$fileType',
				'assets/06' + '.$fileType',
				'assets/09' + '.$fileType',
		], false, // --------------------- progress handler ---------------------

			function(index:Int, loaded:Int, size:Int) {
				trace(' $index progress ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
			},

			function(loaded:Int, size:Int) {
				trace(' Progress overall: ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
			},

			// --------------------- load handler ---------------------
			function(index:Int, bytes:Bytes) {
				trace('$index loaded completely.');

				// another way:
				// sources[index] = new AudioSource(AudioBuffer.fromBytes(bytes));
				// half, we can also shuffle the indizes here (^_^)
				// sources.push(new AudioSource(AudioBuffer.fromBytes(bytes)));
			},

			function(bytesArray:Array<Bytes>) {
				trace(' --- all data loaded ---');

				sources = [];
				textureDatas = [];
			
				for (bytes in bytesArray) {
					
					var buffer = AudioBuffer.fromBytes(bytes);
					sources.push(new AudioSource(buffer));

					var wav:WAVE = readWAVE(bytes);
					var width:Int = Math.ceil(wav.data.length / wav.header.channels / (wav.header.bitsPerSample / 8));
					var height = 1;
					textureDatas.push(new TextureData(width, height, TextureFormat.R, wav.data));
				}

				window.onMouseDown.add((x, y, button) -> onMouseClicked(x, y));
				window.onMouseMove.add((x, y) -> onMouseMoved(x, y));
			});
	}

	function readWAVE(bytes:Bytes):WAVE {
		var reader = new format.wav.Reader(new BytesInput(bytes));
		return reader.read();
	}

	/*
	function playAll() {
		for (source in sources) {
			source.play();
		}
	}
	*/
	
	function randomise(min, max) {
		return Math.floor(Math.random() * (max - min + 1)) + min;
	}
  

	// after all sounds is loaded
	function onMouseClicked(x:Float, y:Float)
	{
		if(buffer.length > 0) return;

		for (source in sources) {
			var bird = new Emitter(source, randomise(20, window.width - 20), randomise(20, window.height - 20), 32, 32, Color.RED1, Color.random(), 0.9);
			buffer.addElement(bird);
			// bird.play();
			setGain(bird, x, y);
			buffer.update();
			bird.playRepeated(2000, 1000);

		}

	}


	function onMouseMoved(x:Float, y:Float) {
		for(i in 0...buffer.length){
			var bird = buffer.getElement(i);
			setGain(bird, x, y);
		}
		buffer.update();
	}
	
	function setGain(bird:Emitter, x:Float, y:Float){
		var distance = Math.sqrt((bird.x - x) * (bird.x - x) + (bird.y - y) * (bird.y - y));
		// todo : apply distance better
		bird.setGain(distance / window.width);
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
