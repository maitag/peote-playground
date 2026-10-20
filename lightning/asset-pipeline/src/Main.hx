package;

import peote.view.Uniform.UniformFloat;
import asset.Tile;
import asset.Sheet;
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

	// displays
	var uiElem:Control;
	var uiLight:Control;
	var chain:Chain;
	
	// buffers
	// var bufferTest = new Buffer<Elem>(111);
	var bufferElem:Buffer<Elem>;
	var bufferLight:Buffer<ElemLight>;

	// elements into control
	var elems = new Array<Elem>();
	var elem(get, never):Elem; function get_elem() return elems[ui_elem.value];

	// lights into control
	var lights = new Array<ElemLight>();
	var light(get, never):ElemLight; function get_light() return lights[ui_light.value];

	// debug uniforms
	static public var u_debug0 = new UniformFloat(1.0);
	static public var u_debug1 = new UniformFloat(1.0);
	static public var u_debug2 = new UniformFloat(1.0);

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window, Color.GREY1);

		bufferElem = new Buffer<Elem>(1024, 512);
		bufferLight = new Buffer<ElemLight>(1024, 512);


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
		// chain = new Chain(peoteView, 4, 4, 592, 592,
		chain = new Chain(peoteView, 0, 0, window.width, window.height,
			bufferElem, bufferLight, 
			normalDepthTextures, uvAoAlphaTextures, haxeUVTexture	
		);

		// chain.zoom=1; chain.width *= Std.int(chain.zoom); chain.height*= Std.int(chain.zoom);

		peoteView.addDisplay(chain);
		
		// ---------- add some elements by default ----------
		var x:Int = 10;
		var y:Int = 10;

		for (tileID in TileID) {
			addElem(x, y, tileID);
			var sheet = Tiles.sheets[Tiles.tile(tileID).sheet];
			x += sheet.width + 10;
			// if (x > chain.width) y += sheet.height + 10;
			if (x > 127) {
				y += sheet.height + 10;
				x = 0;
			}
		}
		chooseElem(9);
		// for (tileID in TileID) trace(TileID.names[tileID]);
		
		// ---------- add lights -----------
		addLight(10, 10, 256, Color.YELLOW);
		addLight(100, 100, 256, Color.RED);
		addLight(200, 150, 256, Color.BLUE);//0xffff66ff);
		addLight(100, 385, 360, Color.ORANGE);

		//debug
		addLight(49, 205, 430, Color.WHITE, 0.195); ui_mode.value=0;
		
		chooseLight(4);

		// ----------- ui-control -----------
		peoteView.addDisplay( uiElem = uiElemControl() );
		peoteView.addDisplay( uiLight = uiLightControl() );
		PeoteUIDisplay.registerEvents(window);
	
		// ----------------------------------------------------

		peoteView.start();
		
		// add mouse events:
		window.onMouseDown.add(_onMouseDown);
		window.onMouseUp.add(_onMouseUp);
		window.onMouseMove.add(_onMouseMove);
		window.onMouseWheel.add(_onMouseWheel);
	}
	
	// -----------------------------------------------------------------------------------
	// -----------------------------------------------------------------------------------
	// -----------------------------------------------------------------------------------

	function addLight(x:Int, y:Int, size:Int, color:Color, depth:Float = 0.0) {
		lights.push( new ElemLight(x, y, size, color, depth) );
		ui_light.value = lights.length - 1;
		bufferLight.addElement(light);
		chooseLight(ui_light.value);
	}

	function addElem(x:Int, y:Int, tileID:TileID) {
		var tile = Tiles.tile(tileID);
		var sheet = Tiles.sheets[tile.sheet];

		var e = new Elem(x+(sheet.width>>1), y+(sheet.height>>1), sheet.width, sheet.height, tileID, tile.sheet);
		
		e.animID = 0;
		e.tile   =  tile.anim( tile.animID[0] ).start;
		
		elems.push( e );
		
		bufferElem.addElement(e);
		ui_elem.value = elems.length - 1;

		chooseElem(ui_elem.value);
	}

	function delLight(index:Int) {
		if (lights.length == 1) return; // keep one at least
		bufferLight.removeElement(lights[index]);
		lights.splice( index, 1 );
		ui_light.value--;
		chooseLight(ui_light.value);
	}

	function delElem(index:Int) {
		if (elems.length == 1) return; // keep one at least
		bufferElem.removeElement(elems[index]);
		elems.splice( index, 1 );
		ui_elem.value--;
		chooseElem(ui_elem.value);
	}

	function chooseLight(index:Int) {
		if (index < 0) index = 0 else if (index > lights.length-1) index = lights.length-1;
		ui_light.value = index;		
		ui_light_x.value = light.x;
		ui_light_y.value = light.y;
		ui_light_size.value = light.size;
		ui_light_depth.value = light.depth;
		ui_light_r.value = light.color.rF;
		ui_light_g.value = light.color.gF;
		ui_light_b.value = light.color.bF;
	}

	function chooseElem(index:Int) {
		if (index < 0) index = 0 else if (index > elems.length-1) index = elems.length-1;
		ui_elem.value = index;		
		ui_elem_x.value = elem.x;
		ui_elem_y.value = elem.y;
		ui_elem_r.value = elem.r;
		ui_elem_depth.value = elem.depth;
		// ui_elem_r.value = elem.color.rF;
		// ui_elem_g.value = elem.color.gF;
		// ui_elem_b.value = elem.color.bF;

		chooseElemAnim(elem.animID);
	}

	function chooseElemAnim(index:Int) {
		var tile = Tiles.tile(elem.tileID);

		if (index < 0) index = tile.animID.length-1;
		else if (index > tile.animID.length-1) index = 0;

		elem.animID = index;
		ui_elem_animName.value = AnimID.names[ tile.animID[index] ];
		ui_elem_anim.value = index;
	}

	function playElemAnim() {
		var tile = Tiles.tile(elem.tileID);
		var anim = tile.anim(tile.animID[elem.animID]);
		elem.animTile(anim.start, anim.end);
		elem.timeTile(peoteView.time, (anim.end - anim.start + 1)/Tiles.FPS);
		bufferElem.updateElement(elem);
	}

	// -----------------------------------------------------------
	// ----------------- UI CONTROL ------------------------------
	// -----------------------------------------------------------
	var ui_light = new IntValue(0);
	var ui_light_x = new IntValue(0);
	var ui_light_y = new IntValue(0);
	var ui_light_size = new IntValue(0);
	var ui_light_depth = new FloatValue(0);

	var ui_light_r = new FloatValue(0.0);
	var ui_light_g = new FloatValue(0.0);
	var ui_light_b = new FloatValue(0.0);

	var ui_light_debug = new BoolValue(false);
	var ui_mode = new RadioValue(1);

	function uiLightControl():Control return new Control("light control", "assets/font/hack_ascii_small.json", window.width-296, 0, 296, 140, //Color.BLUE1,
	[
		// Slider("", 70, new FloatValue(0), -180.0, 180.0, (v)->{u_debug0.value=v;trace(v);}),
		// Slider("", 70, new FloatValue(0), -180.0, 180.0, (v)->{u_debug1.value=v;trace(v);}),
		// Slider("", 70, new FloatValue(0), -180.0, 180.0, (v)->{u_debug2.value=v;trace(v);}),
		Col([
			RadioButton("Light", 80, ui_mode, 0, (v)->{ trace(v); } )
			// ,Checkbox("debug", 60, ui_light_debug, (v)->{ trace(v); } ) // <- LATER ;:) -> into buffet la grAnde .)
		]),
		Col(68, [
			Row(90, [					
				Col([
					Button  ("<", 24, ()->chooseLight(ui_light.value-1) ),
					OutputInt(27, Center, ui_light),
					Button  (">", 24, ()->chooseLight(ui_light.value+1) )
				]),
				Col([
					Button  ("Add", 40, ()->addLight(150,150,200,Color.ORANGE) ),
					Button  ("Del", 40, ()->delLight(ui_light) )
				]),
				Col([Label("d", 18), InputFloat(60, Right, ui_light_depth, 3, (v:Float) ->{ light.depth=v; bufferLight.updateElement(light); })])
			]),
			Row(70, [
				Col([Label("x", 10), InputInt(Right, ui_light_x, (v:Int) ->{ light.x=v; bufferLight.updateElement(light); })]),
				Col([Label("y", 10), InputInt(Right, ui_light_y, (v:Int) ->{ light.y=v; bufferLight.updateElement(light); })]),
				Col([Label("s", 10), InputInt(Right, ui_light_size, (v:Int) ->{ light.size=v; bufferLight.updateElement(light); })])
			]),
			Row(90, [
				Col([Label("r", 10), Slider("", 70, ui_light_r, 0.0, 1.0, (v)->{ light.color.rF=v; bufferLight.updateElement(light);} )]),
				Col([Label("g", 10), Slider("", 70, ui_light_g, 0.0, 1.0, (v)->{ light.color.gF=v; bufferLight.updateElement(light);} )]),
				Col([Label("b", 10), Slider("", 70, ui_light_b, 0.0, 1.0, (v)->{ light.color.bF=v; bufferLight.updateElement(light);} )])
			]),
		]),
	]);
		
	// -----------------------------------------------------------------
	var ui_elem = new IntValue(0);
	var ui_elem_x = new IntValue(0);
	var ui_elem_y = new IntValue(0);
	var ui_elem_r = new FloatValue(0);
	var ui_elem_depth = new FloatValue(0);
	// var ui_elem_r = new FloatValue(0.0);
	// var ui_elem_g = new FloatValue(0.0);
	// var ui_elem_b = new FloatValue(0.0);
	var ui_elem_anim = new IntValue(0);
	var ui_elem_animName = new StringValue("");
	
	function uiElemControl():Control return new Control("Assets", "assets/font/hack_ascii_small.json", window.width-203, 142, 203, 400, //Color.GREEN1,
	[
		Col([
			RadioButton("Element", 80, ui_mode, 1, (v)->{ trace(v); } )
		]),
		Col(68, [
			Row(90, [					
				Col([
					Button  ("<", 24, ()->chooseElem(ui_elem.value-1) ),
					OutputInt(27, Center, ui_elem),
					Button  (">", 24, ()->chooseElem(ui_elem.value+1) )
				]),
				Col([Button  ("Del", 40, ()->delElem(ui_elem.value) )]),
				Col([Label("d", 18), InputFloat(60, Right, ui_elem_depth, 3, (v:Float) ->{ elem.depth=v; bufferElem.updateElement(elem); })])
			]),
			Row(70, [
				Col([Label("x", 10), InputInt(Right, ui_elem_x, (v:Int) ->{ elem.x=v; bufferElem.updateElement(elem); })]),
				Col([Label("y", 10), InputInt(Right, ui_elem_y, (v:Int) ->{ elem.y=v; bufferElem.updateElement(elem); })]),
				Col([Label("r", 10), InputFloat(Right, ui_elem_r, (v:Float) ->{ elem.r=v; bufferElem.updateElement(elem); })])
			])
		]),
		Col([
			Button("play",44, ()->{playElemAnim();} ),
		]),
		Col([
			Button  ("<", 24, ()->chooseElemAnim(ui_elem_anim.value-1) ),
			OutputString(109, Center, ui_elem_animName),
			Button  (">", 24, ()->chooseElemAnim(ui_elem_anim.value+1) )
		]),
		Label("add:")
	].concat([ for (tileID in TileID)
		Button( TileID.names[tileID], 24, ()->{
			addElem(150, 150, tileID);
		})
	]));


	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	var mx:Int = 0;
	var my:Int = 0;
	var isMouseDown = false;
	var downX:Float = 0;
	var downY:Float = 0;
	var isShift = false;
	var isCtrl = false;
	var uiLightAtFront=true;
	var dragChain = false;

	function _onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		if (uiElem.isPointInside(Std.int(x), Std.int(y))) {
			if (uiLightAtFront) {
				uiElem.swapDisplay(uiLight);
				uiLightAtFront = false;
				ui_mode.value = 1;
			}
			return;
		}

		if (uiLight.isPointInside(Std.int(x), Std.int(y))) {
			if (!uiLightAtFront) {
				uiLight.swapDisplay(uiElem);
				uiLightAtFront = true;
				ui_mode.value = 0;
			}
			return;
		}

		isMouseDown = true;
		
		var picked:Int = chain.pickElement_FB(x, y);
		if (picked>=0) {
			// ui_elem.value = elems.indexOf(bufferElem.getElement(picked));
			// ui_elem_animName.value = AnimID.names[ elem.animID ];
			chooseElem(elems.indexOf(bufferElem.getElement(picked)));
			downX = elem.x - chain.localX_FB(x);
			downY = elem.y - chain.localY_FB(y);
		}
		else {
			downX = x-chain.xOffset_FB;
			downY = y-chain.yOffset_FB;
			dragChain = true;
		}
	}

	function _onMouseUp (x:Float, y:Float, button:MouseButton):Void {
		isMouseDown = false;
		dragChain = false;
	}
	
	function _onMouseMove (x:Float, y:Float):Void
	{
		mx = Std.int(x);
		my = Std.int(y);
		if (isMouseDown) {
			if (ui_mode.value == 0) {
				if (lights.length == 0) return;
				light.x = Std.int(chain.localX_FB(x));
				light.y = Std.int(chain.localY_FB(y));
				bufferLight.updateElement(light);
				ui_light_x.value = light.x;
				ui_light_y.value = light.y;
			}
			else {
				if (dragChain) {
					chain.xOffset_FB = (mx - downX);
					chain.yOffset_FB = (my - downY);
				}
				else {
					if (elems.length == 0) return;
					elem.x = Std.int(chain.localX_FB(x)+downX);
					elem.y = Std.int(chain.localY_FB(y)+downY);
					bufferElem.updateElement(elem);
					ui_elem_x.value = elem.x;
					ui_elem_y.value = elem.y;
				}
			}
		}	
	}	
	
	function _onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void
	{
		if (uiElem.isPointInside(mx, my)||uiLight.isPointInside(mx, my)) return;
		if (isShift) 
		{
			if (ui_mode.value == 0) {
				if (lights.length == 0) return;
				light.depth += ( (deltaY > 0) ? 1 : -1  ) * 0.005;
				ui_light_depth.value = light.depth;
				bufferLight.updateElement(light);
			}
			else {
				if (elems.length == 0) return;
				elem.depth += ( (deltaY > 0) ? 1 : -1  ) * 0.005;
				ui_elem_depth.value = elem.depth;
				bufferElem.updateElement(elem);
			}
		}
		else if (isCtrl)
		{
			if (ui_mode.value == 0) {
				if (lights.length == 0) return;
				light.size += ( (deltaY > 0) ? 1 : -1  ) * 10;
				ui_light_size.value = light.size;
				bufferLight.updateElement(light);
			}
			else {
				if (elems.length == 0) return;
				elem.r += ( (deltaY > 0) ? 1 : -1  ) * 5;
				ui_elem_r.value = elem.r;
				bufferElem.updateElement(elem);
			}
		}
		else {
			chain.zoomAt(mx, my, deltaY, 1.2);
			// chain.zoom_FB = Control.round( chain.zoom_FB, 1 );
		}
	}

	// ----------------- KEYBOARD EVENTS ---------------------------
	override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void
	{
		if (keyCode == KeyCode.LEFT_SHIFT) isShift = true;
		if (keyCode == KeyCode.LEFT_CTRL) isCtrl = true;
		else if (keyCode == KeyCode.SPACE) if (peoteView.isRun) peoteView.stop() else peoteView.start();
	}

	override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void
	{
		if (keyCode == KeyCode.LEFT_SHIFT) isShift = false;
		if (keyCode == KeyCode.LEFT_CTRL) isCtrl = false;
	}

	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	
}
