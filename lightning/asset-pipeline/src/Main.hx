package;

import haxe.CallStack;
import haxe.Timer;

import lime.app.Application;
import lime.graphics.Image;
import lime.ui.*;

import peote.view.*;
import peote.ui.PeoteUIDisplay;
import peote.ui.config.HAlign;
import peote.ui.tool.Control;
import peote.ui.tool.ControlItem;
import peote.ui.tool.ControlValues;

import asset.Util;
import asset.generated.Tiles;
import asset.generated.Tiles.TileID;
import asset.generated.Tiles.AnimID;

import fb_chain.*;
import fb_chain.light.*;

class Main extends Application
{
	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES: try startSample(window) catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	var peoteView:PeoteView;

	var ui:Control;
	var chain:Chain;
	
	var bufferElem:Buffer<Elem> = new Buffer<Elem>(1024, 512);
	var bufferLight:Buffer<ElemLight> = new Buffer<ElemLight>(1024, 512);

	// elements into control
	var elems = new Array<Elem>();
	var elem:Elem; function get_elem() return elems[ui_elem.value];

	// lights into control
	var lights = new Array<ElemLight>();
	var light(get, never):ElemLight; function get_light() return lights[ui_light.value];

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window, Color.BLACK);

		var textureConfig:TextureConfig = {
			format:TextureFormat.RGBA,
			smoothExpand: false,
			smoothShrink: false,
			powerOfTwo: false
		};

		var normalDepthTextures = Util.loadTextures(Tiles.sheets, "normal_depth", textureConfig, false);
		var uvAoAlphaTextures   = Util.loadTextures(Tiles.sheets, "uv_ao_alpha" , textureConfig, false);

		var haxeUVTexture = new Texture(256, 256, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true});
		Load.image( "assets/haxe.png", false, function(image:Image) haxeUVTexture.setData(image) );

		// -------- combine both fb-textures (add dynamic lights to the pre-lighted) --------- 
		chain = new Chain(peoteView, 0, 0, 512, 512, 
			bufferElem, bufferLight, 
			normalDepthTextures, uvAoAlphaTextures, haxeUVTexture	
		);

		chain.zoom=2;
		chain.width *= Std.int(chain.zoom);
		chain.height*= Std.int(chain.zoom);

		peoteView.addDisplay(chain);
		
		// ---------- add elements ----------
		var x:Int = 10;
		var y:Int = 10;

		for (tileID in TileID)
		{
			trace(TileID.names[tileID]);

			var tile = Tiles.tile(tileID);
			var sheet = Tiles.sheets[tile.sheet];

			for (animID in tile.animID)
			{
				trace("  "+ AnimID.names[animID], tile.sheet, tile.anim(animID).start, tile.anim(animID).end);

				var e = new Elem(x, y, sheet.width, sheet.height, sheet.gap, tile.sheet);
				
				// TODO: add element fun
				var anim = tile.anim(animID);
				e.animTile(anim.start, anim.end);
				e.timeTile(0, (anim.end - anim.start + 1)/Tiles.FPS);
		
				bufferElem.addElement(e);

				x += sheet.width + 10;
				if (x > chain.width) y += sheet.height + 10;
			}
		}
			

		// ---------- add lights -----------
		addLight(10, 10, 256, Color.YELLOW);
		addLight(100, 100, 256, Color.RED);
		addLight(0, 0, 256, Color.BLUE);//0xffff66ff);
		chooseLight(2);

		// ----------- ui-control -----------
		ui = ui_control();
		peoteView.addDisplay(ui);
	
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
	
	function addLight(x:Int, y:Int, size:Int, color:Color) {
		lights.push( new ElemLight(x, y, size, color) );
		ui_light.value = lights.length - 1;
		bufferLight.addElement(light);
	}

	function chooseLight(index:Int) {
		if (index < 0) index = 0 else if (index > lights.length-1) index = lights.length-1;
		ui_light.value = index;
		// sry Slushi -> still have to do some repetive work now byside *lol
		ui_light_x.value = light.x;
		ui_light_y.value = light.y;
		ui_light_depth.value = light.depth;

		ui_light_r.value = light.color.rF;
		ui_light_g.value = light.color.gF;
		ui_light_b.value = light.color.bF;
	}

	function chooseElem(index:Int) {
		if (index < 0) index = 0 else if (index > elems.length-1) index = elems.length-1;
		ui_elem.value = index;
		// sry Slushi -> still have to do some repetive work now byside *lol
		ui_elem_x.value = elem.x;
		ui_elem_y.value = elem.y;
		ui_elem_depth.value = elem.depth;

		// ui_elem_r.value = light.color.rF;
		// ui_elem_g.value = light.color.gF;
		// ui_elem_b.value = light.color.bF;
	}

	// -----------------------------------------------------------
	// ----------------- UI CONTROL ------------------------------
	// -----------------------------------------------------------
	var ui_light = new IntValue(0);
	var ui_light_x = new IntValue(0);
	var ui_light_y = new IntValue(0);
	var ui_light_depth = new FloatValue(0);

	var ui_light_r = new FloatValue(0.0);
	var ui_light_g = new FloatValue(0.0);
	var ui_light_b = new FloatValue(0.0);

	var ui_elem = new IntValue(0);
	var ui_elem_x = new IntValue(0);
	var ui_elem_y = new IntValue(0);
	var ui_elem_depth = new FloatValue(0);
	// var ui_elem_r = new FloatValue(0.0);
	// var ui_elem_g = new FloatValue(0.0);
	// var ui_elem_b = new FloatValue(0.0);

	function ui_control():Control {
		return new Control("light control", "assets/font/hack_ascii_small.json", window.width-296, 0, 296, 150,
		[
			Col([ Button  ("Light", 60,  ()->{} ) ]),
			Col(68, [
				Row(90, [					
					Col([
						Button  ("<", 24, ()->chooseLight(ui_light.value-1) ),
						OutputInt(27, Center, ui_light),
						Button  (">", 24, ()->chooseLight(ui_light.value+1) )
					]),
					Col([Button  ("Add", 40, ()->{} ), Button  ("Del", 40, ()->{} )]),
					Col([Label("s", 10), Slider("", 70, 10, 20)] )
				]),
				Row(70, [
					Col([Label("x", 10), InputInt(Right, ui_light_x, (v:Int) ->{ light.x=v; bufferLight.updateElement(light); })] ),
					Col([Label("y", 10), InputInt(Right, ui_light_y, (v:Int) ->{ light.y=v; bufferLight.updateElement(light); })] ), // looks shit, anyway .)
					Col([Label("d", 10), InputFloat(Right, ui_light_depth, (v:Float) ->{ trace("depth later into .)", v);})] )
				]),
				Row(90, [
					Col([Label("r", 10), Slider("", 70, ui_light_r, 0.0, 1.0, (v)->{ light.color.rF=v; bufferLight.updateElement(light);} )] ),
					Col([Label("g", 10), Slider("", 70, ui_light_g, 0.0, 1.0, (v)->{ light.color.gF=v; bufferLight.updateElement(light);} )] ),
					Col([Label("b", 10), Slider("", 70, ui_light_b, 0.0, 1.0, (v)->{ light.color.bF=v; bufferLight.updateElement(light);} )] )
				]),
			]),
			Col([ Button  ("Element", 60,  ()->{} ) ]),
			Col(68, [
				Row(90, [					
					Col([
						Button  ("<", 24, ()->chooseElem(ui_elem.value-1) ),
						OutputInt(27, Center, ui_elem),
						Button  (">", 24, ()->chooseElem(ui_elem.value+1) )
					]),
					Col([Button  ("Add", 40, ()->{} ), Button  ("Del", 40, ()->{} )]),
					Col([Label("s", 10), Slider("", 70, 10, 20)] )
				]),
				Row(70, [
					Col([Label("x", 10), InputInt(Right, ui_elem_x, (v:Int) ->{ elem.x=v; bufferElem.updateElement(elem); })] ),
					Col([Label("y", 10), InputInt(Right, ui_elem_y, (v:Int) ->{ elem.y=v; bufferElem.updateElement(elem); })] ),
					Col([Label("d", 10), InputFloat(Right, ui_elem_depth, (v:Float) ->{ trace("depth later into .)", v);})] )
				])
				/*,
				Row(90, [
					Col([Label("r", 10), Slider("", 70, ui_elem_r, 0.0, 1.0, (v)->{ elem.color.rF=v; bufferLight.updateElement(elem);} )] ),
					Col([Label("g", 10), Slider("", 70, ui_elem_g, 0.0, 1.0, (v)->{ elem.color.gF=v; bufferLight.updateElement(elem);} )] ),
					Col([Label("b", 10), Slider("", 70, ui_elem_b, 0.0, 1.0, (v)->{ elem.color.bF=v; bufferLight.updateElement(elem);} )] )
				]),*/
			]),
		
		]);
	}

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	var mx:Int = 0;
	var my:Int = 0;
	var isMouseDown = false;
	var downX:Int = 0;
	var downY:Int = 0;
	var isShift = false;
	
	function _onMouseMove (x:Float, y:Float):Void {
		mx = Std.int(x);
		my = Std.int(y);
		if (isMouseDown) {
			light.x = Std.int(x/peoteView.zoom/chain.zoom);
			light.y = Std.int(y/peoteView.zoom/chain.zoom);
			bufferLight.updateElement(light);
			ui_light_x.value = light.x;
			ui_light_y.value = light.y;
		}	
	}	
	
	function _onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		if (ui.isPointInside(mx, my)) return;
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
	
	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void {
		if (ui.isPointInside(Std.int(x), Std.int(y))) return;
		downX = Std.int(x);
		downY = Std.int(y);
		isMouseDown = true;
	}
	override function onMouseUp (x:Float, y:Float, button:MouseButton):Void isMouseDown = false;

	// override function onMouseMove (x:Float, y:Float):Void { }
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
