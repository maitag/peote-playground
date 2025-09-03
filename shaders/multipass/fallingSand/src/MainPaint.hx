package;

import haxe.CallStack;
import haxe.Resource; // to include "shaderPasses.glsl" file

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyModifier;
import lime.ui.KeyCode;

import peote.view.*;

@:publicFields
class ElemPaint implements Element
{
	@posX var x:Int = 0;
	@posY var y:Int = 0;
	@sizeX var w:Int;
	@sizeY var h:Int;
	@pivotX @formula("w*0.5") var px:Float;
	@pivotY @formula("h*0.5") var py:Float;
	@color var color:Color = 0x01ffffff;

	public function new(width:Int, height:Int) {
		w = width;
		h = height;
	}
}


class MainPaint extends Application
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

	var paintBuffer:Buffer<ElemPaint>;
	var paintProgram:Program;
	var elemPaint:ElemPaint;
		
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window, Color.GREY2);

		var w:Int = 128;
		var h:Int = 128;

		// initial texture data
		var startTextureData = new TextureData(w, h, TextureFormat.RGBA);
		// for (y in 32...96) for (x in 54...74) startTextureData.setColor_RGBA(x, y, 0x010099ff);

		// initial texture
		var fbTexture = new Texture(w, h, 1, {format:TextureFormat.RGBA, powerOfTwo:false} );
		fbTexture.setData(startTextureData);
		
		// inits Displays and Programs into Multipass->Shader-QUEUE:
		var fallingSand = new Multipass( peoteView, fbTexture, Resource.getString("shaderPasses.glsl") );

		// init program to use an element as paintbrush 
		fallingSand.displayView.zoom = 4.68;

		paintBuffer = new Buffer<ElemPaint>(10);
		elemPaint = new ElemPaint(6, 6);
		// paintBuffer.addElement(elemPaint);

		paintProgram = new Program(paintBuffer);
		fallingSand.displayPass1.addProgram(paintProgram);





		fallingSand.renderStart();
		// new haxe.Timer(500).run = () -> fallingSand.renderStep();		

		// let the uTime uniform rotate to get a better random seed :)
		peoteView.start();
	}
	
	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// ----------------- MOUSE EVENTS ------------------------------
	
	override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {
		// TODO: need to implement in peoteView to let it work simmiliar as in Display:
		// paintProgram.renderFramebufferEnabled = true;
		paintBuffer.addElement(elemPaint);
	}

	override function onMouseMove (x:Float, y:Float):Void {
		if (elemPaint != null) {
			elemPaint.x = Math.round(x/4.68);
			elemPaint.y = Math.round(y/4.68);
			paintBuffer.update();
		}
	}

	override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {
		// TODO: need to implement in peoteView to let it work simmiliar as in Display:
		// paintProgram..renderFramebufferEnabled = false;
		paintBuffer.removeElement(elemPaint);
	}

	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void {
		switch(keyCode) {
			case NUMBER_1: elemPaint.color = 0x0155ffff;
			case NUMBER_2: elemPaint.color = 0x020044ff;
			case NUMBER_3: elemPaint.color = 0x000000ff;
			default:
		}
	}
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	
}
