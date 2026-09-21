package;

import peote.ui.PeoteUIDisplay;
import haxe.CallStack;
import haxe.Timer;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseWheelMode;
import lime.graphics.Image;

import peote.view.*;

import asset.Util;
import asset.generated.Tiles;
import asset.generated.Tiles.TileID;
import asset.generated.Tiles.AnimID;

import ui.Control;
import ui.ControlItem;
import fb_chain.*;
import fb_chain.light.*;

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

	var ui:Control;
	var chain:Chain;
	
	var bufferElem:Buffer<Elem>;
	var bufferLight:Buffer<ElemLight>;

	var light:ElemLight; // one light is controled by mouse


	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window, Color.BLACK);

		// little ui
		// i am not 100% satisfactionized at now by the -> "need of size" extra arguments ;) ->inside<-
		// ANY WAY ;:) -> iAm like IT:
		ui = new Control("light control", 430, 10, 360, 300, [
			Col(50, [
				Button  ("button", 80,  (       )->{ trace("button");} ),
				Slider  ("label:", 100, (v:Float)->{ trace("slider", v);} ),
				Label   ("label:", 60),
				Checkbox("on/off", 60,  (v:Bool) ->{ trace("checkbox", v);} )
			]),
			Slider("label:", 50,(v:Float)->{ trace("slider", v);} ),
			Seperator
		]);
		// ^^much T O -> DO \o/ ooooooooooooooooooooooooooooooooooooooo


		var textureConfig:TextureConfig = {
			format:TextureFormat.RGBA,
			smoothExpand: false,
			smoothShrink: false,
			powerOfTwo: false
		};

		var normalDepthTextures = Util.loadTextures(Tiles.sheets, "normal_depth", textureConfig);
		var uvAoAlphaTextures   = Util.loadTextures(Tiles.sheets, "uv_ao_alpha" , textureConfig);

		var haxeUVTexture = new Texture(256, 256, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true});
		Load.image( "assets/haxe.png", true, // debug
			function(image:Image) { // after image is loaded
				haxeUVTexture.setData(image);
			}
		);

		// ------ create Buffers for Elements and Lights ------

		bufferElem = new Buffer<Elem>(1024, 512);
		bufferLight = new Buffer<ElemLight>(1024, 512);

		// -------- combine both fb-textures (add dynamic lights to the pre-lighted) --------- 
		chain = new Chain(peoteView, 0, 0, 512, 512, 
			bufferElem, bufferLight, 
			normalDepthTextures, uvAoAlphaTextures, haxeUVTexture	
		);

		chain.zoom=4;
		chain.width *= Std.int(chain.zoom);
		chain.height*= Std.int(chain.zoom);

		peoteView.addDisplay(chain);
		// Timer.delay(()->peoteView.removeDisplay(chain),1000); Timer.delay(()->peoteView.addDisplay(chain),3000);
		
		peoteView.addDisplay(ui);


		// ---------- add elements ----------

		var e1 = new Elem(40,30);
		e1.animTile(0, 0);    // params: start-tile, end-tile
		e1.timeTile(0.0, 2.1); // params: start-time, duration
		bufferElem.addElement(e1);

		var e2 = new Elem(80,30);
		e2.animTile(0, 0);    // params: start-tile, end-tile
		e2.timeTile(0.0, 2.1); // params: start-time, duration
		e2.depth = 0.1;
		bufferElem.addElement(e2);
		
				

		// ---------- add lights -----------


		var light1 = new ElemLight(10, 10, 256, Color.YELLOW);
		// bufferLight.addElement(light1);
		
		var light2 = new ElemLight(100, 100, 256, Color.RED);
		// bufferLight.addElement(light2);
		
		// global "mouse-control"-light
		light = new ElemLight(0, 0, 256, 0xffff66ff);
		bufferLight.addElement(light);
		
		
		// ----------------------------------------------------

		#if android
		ui.mouseEnabled = false;
		// uiDisplay.touchEnabled = true;
		ui.zoom=2;
		ui.width *= Std.int(ui.zoom); ui.height*= Std.int(ui.zoom);
		ui.x = width - ui.width;
		#end
		PeoteUIDisplay.registerEvents(window);

		// peoteView.zoom = 2;
		peoteView.start();
		
		// add mouse events to move the light (to not run before it was instantiated):
		window.onMouseMove.add(_onMouseMove);
		window.onMouseWheel.add(_onMouseWheel);

	}
	

	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	


	function _onMouseMove (x:Float, y:Float):Void {
		light.x = Std.int(x/peoteView.zoom/chain.zoom);
		light.y = Std.int(y/peoteView.zoom/chain.zoom);
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
