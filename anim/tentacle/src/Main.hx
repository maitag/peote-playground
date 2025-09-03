package;

import haxe.CallStack;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseWheelMode;
import lime.graphics.Image;

import peote.view.*;

import fb_light.*;

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

		Load.imageArray(["assets/tentacle_normal_depth.png", "assets/tentacle_uv_ao_alpha.png", "assets/haxe.png"], true, function (image:Array<Image>)
		{
			//-----------------------------------------------------
			// ----- create Textures from the loaded images -------
			//-----------------------------------------------------

			var normalDepthTexture = new Texture(image[0].width, image[0].height, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true, tilesX:8, tilesY:3});
			normalDepthTexture.setData(image[0]);

			var uvAoAlphaTexture = new Texture(image[1].width, image[1].height, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true, tilesX:8, tilesY:3});
			uvAoAlphaTexture.setData(image[1]);
			
			var haxeUVTexture = new Texture(image[2].width, image[2].height, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true});
			haxeUVTexture.setData(image[2]);
			

			//----------------------------------------------------
			// ----- create Buffers for Tentacles and Lights -----
			//----------------------------------------------------

			var bufferTentacle = new Buffer<ElementTentacle>(1024, 512);
			bufferLight = new Buffer<ElementLight>(1024, 512);
			

			//-------------------------------------------------
			//           Framebuffer chain  
			//-------------------------------------------------

			// --- render all tentacles uv-mapped, ao-prelightned with alpha and in depth ---
			var uvAoAlphaDepthFB = new UvAoAlphaDepthFB(512, 512, bufferTentacle, normalDepthTexture, uvAoAlphaTexture, haxeUVTexture);
			uvAoAlphaDepthFB.addToPeoteView(peoteView);
			
			// ------ render all normals together to use for lightning -------
			var normalDepthFB = new NormalDepthFB(512, 512, bufferTentacle, normalDepthTexture);
			normalDepthFB.addToPeoteView(peoteView);

			// ------ render all lights while using normalDepthFB texture -----
			var lightFB = new LightFB(512, 512, bufferLight, normalDepthFB.fbTexture);
			lightFB.addToPeoteView(peoteView);
			
			// -------- combine both fb-textures (add dynamic lights to the pre-lighted) --------- 
			var combineDisplay = new CombineDisplay(0, 0, 512, 512, uvAoAlphaDepthFB.fbTexture, lightFB.fbTexture);
			peoteView.addDisplay(combineDisplay);

						
			// ----------------------------------------
			// ---------- add some tentacles ----------
			// ----------------------------------------

			var tentacle1 = new ElementTentacle();
			tentacle1.animTile(0, 24);    // params: start-tile, end-tile
			tentacle1.timeTile(0.0, 2.1); // params: start-time, duration
			bufferTentacle.addElement(tentacle1);
			
			
			var tentacle2 = new ElementTentacle(64, 64, 128, 128, 180, 64, 64);
			// var tentacle2 = new ElementTentacle(264, 264, 500, 500, 180, 64, 64);
			// tentacle2.depth= 0.1;
			tentacle2.animTile(0, 24);    // params: start-tile, end-tile
			tentacle2.timeTile(0.0, 1.9); // params: start-time, duration
			bufferTentacle.addElement(tentacle2);
			

			// --------------------------------------
			// ---------- add some lights -----------
			// --------------------------------------


			var light1 = new ElementLight(10, 10, 256, Color.YELLOW);
			bufferLight.addElement(light1);
			
			var light2 = new ElementLight(100, 100, 256, Color.RED);
			bufferLight.addElement(light2);
			
			// global "mouse-control"-light
			light = new ElementLight(0, 0, 256, 0xffff66ff);
			bufferLight.addElement(light);
			
			
			// ----------------------------------------------------			
			// ----------------------------------------------------			
			// ----------------------------------------------------		

			peoteView.zoom = 4;
			peoteView.start();
			
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
		else if (keyCode == KeyCode.SPACE) if (peoteView.isRun) peoteView.stop() else peoteView.start();
	}	
	override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		if (keyCode == KeyCode.LEFT_SHIFT) isShift = false;
	}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	
}
