package;

import haxe.CallStack;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseWheelMode;
import lime.graphics.Image;

import peote.view.*;
import utils.Loader;


class Main extends Application
{
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	var peoteView:PeoteView;
	
	var light:NormalLight = null; 
	
	var bufferTentacle:Buffer<Tentacle>;
	// bufferLights

	// displayElements
	// displayElementsNormal
	// displayLights


	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window, Color.BLACK);

		#if html5
		// at now this is need because the normalProgram is initialized AFTERWARDS (there it will enable the extension automatically!)
		// -> will be fixed in peote-view soon!
		
		peoteView.gl.getExtension("EXT_color_buffer_float");
		#end

		var normalDisplay = new Display(0, 0, 512, 512);
		var normalDisplayTexture = new Texture(512, 512, 1, {format:TextureFormat.FLOAT_RGBA, smoothExpand: false, smoothShrink: false} );

		peoteView.setFramebuffer(normalDisplay, normalDisplayTexture); // render into -> normalDisplayTexture
		peoteView.addFramebufferDisplay(normalDisplay);

		// to test the normal rendering texture
		normalDisplay.y = 128; peoteView.addDisplay(normalDisplay);
		
		Loader.imageArray(["assets/tentacle_normal_depth.png", "assets/tentacle_uv_ao_alpha.png"], true, function (image:Array<Image>)
		{
			var normalDepthTexture = new Texture(image[0].width, image[0].height);
			normalDepthTexture.setData(image[0]);

			var uvAoAlphaTexture = new Texture(image[1].width, image[1].height);
			uvAoAlphaTexture.setData(image[1]);
			
			bufferTentacle = new Buffer<Tentacle>(1024, 512);
			var normalProgram = new NormalProgram(normalDisplay, bufferTentacle, normalDepthTexture);
			
			var t1 = new Tentacle();
			bufferTentacle.addElement(t1);

			var t2 = new Tentacle(64, 64, 128, 128, 90, 64, 64);
			bufferTentacle.addElement(t2);

			// -------- LIGHT ---------

			var display = new Display(0, 0, window.width, window.height);
			peoteView.addDisplay(display);

			NormalLight.init(display, normalDisplayTexture);
			light = new NormalLight(200, 200, 400);

			// "add" (blendmode!) another light
			// new NormalLight(150, 200, 400);
			

			// TODO: another render-pass to accumulate light-map from texture to the pre-calculated lights by blender
			
			
			peoteView.zoom = 2.0;
			
			// add mouse events to move the light (to not run before it was instantiated):
			window.onMouseMove.add(_onMouseMove);
			window.onMouseWheel.add(_onMouseWheel);
		});
		
		
		//peoteView.start();
		
	}
	
	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	
	function _onMouseMove (x:Float, y:Float):Void {
		light.x = Std.int(x/peoteView.zoom);
		light.y = Std.int(y/peoteView.zoom);
		light.update();
	}	

	var isShift = false;
	
	function _onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		if (isShift) {
			light.size += ( (deltaY > 0) ? 1 : -1  ) * 10;
		}
		else {
			light.depth += ( (deltaY > 0) ? 1 : -1  ) * 0.01;
		}
		trace(light.depth);
		light.update();
	}
	// ----------------- MOUSE EVENTS ------------------------------
	
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseMove (x:Float, y:Float):Void {
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		if (keyCode == KeyCode.LEFT_SHIFT) isShift = true;
	}	
	override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		if (keyCode == KeyCode.LEFT_SHIFT) isShift = false;
	}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	
}
