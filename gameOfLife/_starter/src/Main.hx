package;

import haxe.CallStack;
import haxe.Timer;

import lime.app.Application;
import lime.ui.Window;

import peote.view.*;

class ElemCanvas implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int;
	@posY public var y:Int;
	
	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;
		
	// color (RGBA)
	@color public var c:Color;
		
	public function new(x:Int, y:Int, w:Int, h:Int, c:Color) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.c = c;
	}
}


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
	
	var lastTime:Float;
	var delayTime:Float = 0.1;
	var swap:Bool = false;
	
	var rule:String = '23/3'; // Conway's

	var textureData0:TextureData;
	var textureData1:TextureData;
	var texture:Texture;

	var w:Int = 200;
	var h:Int = 150;
	var scale:Float = 4.0;

	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);

		var display = new Display(0, 0, Std.int(w*scale), Std.int(h*scale));
		display.zoom = scale;
		
		var buffer = new Buffer<ElemCanvas>(1);
		var program = new Program(buffer);

		var elemCanvas = new ElemCanvas(0, 0, w, h, 0xf1c511ff );
		buffer.addElement(elemCanvas);

		peoteView.addDisplay(display);
		display.addProgram(program);

		textureData0 = new TextureData( w, h, TextureFormat.LUMINANCE);
		GameOfLife.genRandomCells(textureData0, Std.int(w/2), Std.int(h/2), w, h);

		textureData1 = new TextureData( w, h, TextureFormat.LUMINANCE);

		texture = new Texture(w, h, 1, {format:TextureFormat.LUMINANCE} );
		// texture = new Texture(w, h, 1, {format:TextureFormat.LUMINANCE, smoothExpand:true} );

		program.setTexture(texture, "custom");
		texture.setData(textureData0);
		
		lastTime = Timer.stamp();
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------
	
	override function update(deltaTime:Int):Void
	{
		if ( Timer.stamp() - lastTime > delayTime)
		{
			lastTime = Timer.stamp();
			
			// change cell automation rule randomly
			if (Math.random() < 0.1) rule = GameOfLife.getRandomRule();

			// calculate next state depending on prev state
			if (swap) {
				GameOfLife.nextLifeGeneration( textureData1, textureData0, rule );
				texture.setData(textureData0);
			}
			else {
				GameOfLife.nextLifeGeneration( textureData0, textureData1, rule );
				texture.setData(textureData1);
			}
			swap = ! swap;
		}
	}
	
	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");		

	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseMove (x:Float, y:Float):Void {}	
	override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {
		if (swap) GameOfLife.genRandomCells(textureData1, Std.int(x/scale), Std.int(y/scale));
		else GameOfLife.genRandomCells(textureData0, Std.int(x/scale), Std.int(y/scale));
	}	
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
