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
	
	var bufferLight:Buffer<ElementLight>;
	var light:ElementLight; // one light is controled by mouse


	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window, Color.BLACK);

		// ----------------------------------------------------------
		// Program that renders all Tentacle Elements -> NORMAL-MAPS
		// ----------------------------------------------------------
		var normalDisplay = new Display(0, 0, 512, 512);
		var normalDisplayTexture = new Texture(512, 512, 1, {format:TextureFormat.FLOAT_RGBA, smoothExpand: false, smoothShrink: false} );

		peoteView.setFramebuffer(normalDisplay, normalDisplayTexture); // render into -> normalDisplayTexture
		peoteView.addFramebufferDisplay(normalDisplay);

		// to test the normal rendering texture
		normalDisplay.y = 128; peoteView.addDisplay(normalDisplay);
		
		
		// ----------------------------------------------------------
		// Program that renders all Light Elements -> using the full NORMAL-MAP from before
		// ----------------------------------------------------------
		var lightDisplay = new Display(0, 0, 512, 512);
		var lightDisplayTexture = new Texture(512, 512, 1, {format:TextureFormat.RGB, smoothExpand: false, smoothShrink: false} );

		peoteView.setFramebuffer(lightDisplay, lightDisplayTexture); // render into -> lightDisplayTexture
		peoteView.addFramebufferDisplay(lightDisplay);

		// to test the normal rendering texture
		lightDisplay.x = 128; lightDisplay.y = 128; peoteView.addDisplay(lightDisplay);

		// ----------------------------------------------------------
		// ----------------------------------------------------------
		// ----------------------------------------------------------
		
		Loader.imageArray(["assets/tentacle_normal_depth.png", "assets/tentacle_uv_ao_alpha.png"], true, function (image:Array<Image>)
		{
			//--------------------------------------
			// TO CALCULATE THE LIGHT BY NORMAL MAPs
			//--------------------------------------
			var normalDepthTexture = new Texture(image[0].width, image[0].height);
			normalDepthTexture.setData(image[0]);

			// -------- setup some tentacles  -----------

			var bufferTentacle = new Buffer<ElementTentacle>(1024, 512);
			var normalProgram = new ProgramNormal(bufferTentacle, normalDepthTexture);
			normalDisplay.addProgram(normalProgram);

			var tentacle1 = new ElementTentacle();
			bufferTentacle.addElement(tentacle1);

			var tentacle2 = new ElementTentacle(64, 64, 128, 128, 90, 64, 64);
			bufferTentacle.addElement(tentacle2);



			// -------- setup some lights  -----------

			bufferLight = new Buffer<ElementLight>(1024, 512);
			var programLight = new ProgramLight(bufferLight, normalDisplayTexture);
			lightDisplay.addProgram(programLight);

			var light1 = new ElementLight(10, 10, 256, Color.YELLOW);
			bufferLight.addElement(light1);

			var light2 = new ElementLight(100, 100, 256, Color.RED);
			bufferLight.addElement(light2);

			// and the global "control"-light (by mouse)
			light = new ElementLight(0, 0, 256);
			bufferLight.addElement(light);



			//----------------------------------------------------------------------------------
			// TO MIX the final lightDisplayTexture up on each Tentacles ambient occlusion color
			//----------------------------------------------------------------------------------
			
			// var uvAoAlphaTexture = new Texture(image[1].width, image[1].height);
			// uvAoAlphaTexture.setData(image[1]);
			
			
			// ----------------------------------------------------			
			peoteView.zoom = 2.0;
			
			// add mouse events to move the light (to not run before it was instantiated):
			window.onMouseMove.add(_onMouseMove);
			window.onMouseWheel.add(_onMouseWheel);
		});
		
		
	}
	
	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	
	function _onMouseMove (x:Float, y:Float):Void {
		light.x = Std.int(x/peoteView.zoom);
		light.y = Std.int(y/peoteView.zoom);
		bufferLight.updateElement(light);
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
		bufferLight.updateElement(light);
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
