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

		// ----------------------------------------------
		// 1) Display that renders all UV-mapped+AO Elements 
		// ----------------------------------------------
		var uvAoAlphaDisplay = new Display(0, 0, 512, 512);
		var uvAoAlphaDisplayFBO = new Texture(512, 512, 1, {format:TextureFormat.RGBA, smoothExpand: false, smoothShrink: false} );

		peoteView.setFramebuffer(uvAoAlphaDisplay, uvAoAlphaDisplayFBO); // render into -> uvAoAlphaDisplayFBO
		peoteView.addFramebufferDisplay(uvAoAlphaDisplay);

		// to test
		uvAoAlphaDisplay.x = 128; uvAoAlphaDisplay.y = 0; peoteView.addDisplay(uvAoAlphaDisplay);


		// ----------------------------------------------------------
		// 2) Display that renders all Tentacle Elements -> NORMAL-MAPS
		// ----------------------------------------------------------
		var normalDisplay = new Display(0, 0, 512, 512);
		var normalDisplayFBO = new Texture(512, 512, 1, {format:TextureFormat.FLOAT_RGBA, smoothExpand: false, smoothShrink: false} );

		peoteView.setFramebuffer(normalDisplay, normalDisplayFBO); // render into -> normalDisplayFBO
		peoteView.addFramebufferDisplay(normalDisplay);

		// to test
		normalDisplay.y = 128; peoteView.addDisplay(normalDisplay);
		
		
		// ----------------------------------------------------------
		// 3) Display that renders all Light Elements -> using the full normalDisplayFBO
		// ----------------------------------------------------------
		var lightDisplay = new Display(0, 0, 512, 512);
		var lightDisplayFBO = new Texture(512, 512, 1, {format:TextureFormat.RGB, smoothExpand: false, smoothShrink: false} );

		peoteView.setFramebuffer(lightDisplay, lightDisplayFBO); // render into -> lightDisplayFBO
		peoteView.addFramebufferDisplay(lightDisplay);

		// to test
		lightDisplay.x = 128; lightDisplay.y = 128; peoteView.addDisplay(lightDisplay);


		// ----------------------------------------------------------
		// ----------------------------------------------------------
		// ----------------------------------------------------------
		
		Loader.imageArray(["assets/tentacle_normal_depth.png", "assets/tentacle_uv_ao_alpha.png", "assets/haxe.png"], true, function (image:Array<Image>)
		{
			// ----- Textures -------
			var normalDepthTexture = new Texture(image[0].width, image[0].height, {format:TextureFormat.RGBA, smoothExpand: false, smoothShrink: false});
			normalDepthTexture.setData(image[0]);

			var uvAoAlphaTexture = new Texture(image[1].width, image[1].height, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true});
			uvAoAlphaTexture.setData(image[1]);
			
			var haxeUVTexture = new Texture(image[2].width, image[2].height, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true});
			haxeUVTexture.setData(image[2]);
			

			// ----- Tentacle and Lights Buffers -----
			var bufferTentacle = new Buffer<ElementTentacle>(1024, 512);
			bufferLight = new Buffer<ElementLight>(1024, 512);
			

			// ------ Tentacle Programs -------
			
			// 1) render all tentacles uv-mapped + ambient-occlusion and alpha + depth into uvAoAlphaDisplayFBO			
			var programUvAoAlpha = new ProgramUvAoAlpha(bufferTentacle, normalDepthTexture, uvAoAlphaTexture, haxeUVTexture);
			uvAoAlphaDisplay.addProgram(programUvAoAlpha);
			
			// 2) render all tentacles with normals and depth into normalDisplayFBO			
			var programNormal = new ProgramNormal(bufferTentacle, normalDepthTexture);
			normalDisplay.addProgram(programNormal);
			

			// ------ Light Program -------

			// 3) render all tentacle-lights into lightDisplayFBO
			var programLight = new ProgramLight(bufferLight, normalDisplayFBO);
			lightDisplay.addProgram(programLight);
			
			
			//-------------------------------------------------
			// TO MIX the aoUvAlphaFBO with the lightDisplayFBO 
			//-------------------------------------------------
			
			// render only one Element into final Program and Display
			var bufferView = new Buffer<ElementView>(1);			
			var programView = new Program(bufferView);

			programView.blendEnabled = true;

			// create texture-layer
			programView.setTexture(uvAoAlphaDisplayFBO, "uvAoAlpha", false);
			programView.setTexture(lightDisplayFBO, "light", true);
			programView.setColorFormula( "vec4( vec3(uvAoAlpha/2.0 + light/2.0), uvAoAlpha.a)" );

			
			// ----------------------------------------------------
			// final view Display what displays the combined result 
			// ----------------------------------------------------
			var viewDisplay = new Display(0, 0, 512, 512);
			peoteView.addDisplay(viewDisplay);

			viewDisplay.addProgram(programView);
			
			bufferView.addElement(new ElementView(0, 0, 512, 512));


						
			// ----------------------------------------------------
			// ---------- add some tentacles and lights -----------
			// ----------------------------------------------------

			var tentacle1 = new ElementTentacle();
			bufferTentacle.addElement(tentacle1);
			
			var tentacle2 = new ElementTentacle(64, 64, 128, 128, 180, 64, 64);
			// tentacle2.depth= 0.1;
			bufferTentacle.addElement(tentacle2);
			
			var light1 = new ElementLight(10, 10, 256, Color.YELLOW);
			bufferLight.addElement(light1);
			
			var light2 = new ElementLight(100, 100, 256, Color.RED);
			bufferLight.addElement(light2);
			
			// global "mouse-control"-light
			light = new ElementLight(0, 0, 256);
			bufferLight.addElement(light);
			
			

			
			// ----------------------------------------------------			
			peoteView.zoom = 2;
			
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
