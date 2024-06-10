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

import fb_light.*;

class Benchmark extends Application
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

		Loader.imageArray(["assets/tentacle_normal_depth.png", "assets/tentacle_uv_ao_alpha.png", "assets/haxe.png"], true, function (image:Array<Image>)
		{
			//-----------------------------------------------------
			// ----- create Textures from the loaded images -------
			//-----------------------------------------------------

			var normalDepthTexture = new Texture(image[0].width, image[0].height, {format:TextureFormat.RGBA, smoothExpand: false, smoothShrink: false, tilesX:8, tilesY:3});
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

			var width = 1600;
			var height = 1200;

			// --- render all tentacles uv-mapped, ao-prelightned with alpha and in depth ---
			var uvAoAlphaDepthFB = new UvAoAlphaDepthFB(width, height, bufferTentacle, normalDepthTexture, uvAoAlphaTexture, haxeUVTexture);
			uvAoAlphaDepthFB.addToPeoteView(peoteView);
			
			// ------ render all normals together to use for lightning -------
			var normalDepthFB = new NormalDepthFB(width, height, bufferTentacle, normalDepthTexture);
			normalDepthFB.addToPeoteView(peoteView);

			// ------ render all lights while using normalDepthFB texture -----
			var lightFB = new LightFB(width, height, bufferLight, normalDepthFB.fbTexture);
			lightFB.addToPeoteView(peoteView);
			
			// -------- combine both fb-textures (add dynamic lights to the pre-lighted) --------- 
			var combineDisplay = new CombineDisplay(0, 0, width, height, uvAoAlphaDepthFB.fbTexture, lightFB.fbTexture);
			peoteView.addDisplay(combineDisplay);

						
			// ----------------------------------------
			// ---------- add some tentacles ----------
			// ----------------------------------------

			for (y in 0 ... 10) {
				for (x in 0 ... 160) {
					var tentacle = new ElementTentacle(x*10, 60+y*115, 128, 128, 180, 64, 64);
					tentacle.depth += 0.1 - Math.random()*0.2;
					// tentacle2.depth= 0.1;
					tentacle.animTile(0, 24);    // params: start-tile, end-tile
					var shift = Math.random();
					tentacle.timeTile(shift + 0.0, shift + 1 + Math.random()*0.5 ); // params: start-time, duration
					bufferTentacle.addElement(tentacle);
				}
			}

			// --------------------------------------
			// ---------- add some lights -----------
			// --------------------------------------

			for (y in 0 ... 10) {
				for (x in 0 ... 40) {
					/*var l = new ElementLight(
						Std.int(Math.random()*40 + 40*x - 20), Std.int(Math.random()*100 + 10+y*115),
						256, Color.FloatRGB(Math.random()*0.3,Math.random()*0.3,Math.random()*0.2) );
					*/
					var l = new ElementLight(0, Std.int(Math.random()*100 + 10+y*115), 256, Color.FloatRGB(Math.random()*0.2,Math.random()*0.2,Math.random()*0.3));
					l.animPosX(-128, 1600+128);
					var shift = Math.random();
					l.timePosX(shift, shift + 5 + Math.random()*3);
					l.depth = Math.random()*0.3;
					bufferLight.addElement(l);
				}
			}
			/*
			var light1 = new ElementLight(10, 10, 256, Color.YELLOW);
			bufferLight.addElement(light1);
			
			var light2 = new ElementLight(100, 100, 256, Color.RED);
			bufferLight.addElement(light2);
			*/

			// global "mouse-control"-light
			light = new ElementLight(0, 0, 768, 0xffff66ff);
			light.depth = 0.1;
			bufferLight.addElement(light);
			
			
			// ----------------------------------------------------			
			// ----------------------------------------------------			
			// ----------------------------------------------------		

			peoteView.zoom = 1;
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
	}	
	override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		if (keyCode == KeyCode.LEFT_SHIFT) isShift = false;
	}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	
}
