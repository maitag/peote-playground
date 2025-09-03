package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.Image;

import peote.view.*;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.UITextLine;
import peote.ui.style.*;
import peote.ui.config.*;
import peote.ui.event.*;

import peote.ui.style.interfaces.FontStyle;

// ------------------------------------------
// --- using a custom FontStyle here --------
// ------------------------------------------

@packed // this is need for ttfcompile fonts (gl3font)
@globalLineSpace // all pageLines using the same page.lineSpace (gap to next line into page)
@:structInit
class MyFontStyle implements FontStyle
{
	public var color:Color = Color.GREEN;
	//public var color:Color = Color.GREEN.setAlpha(0.5);
	public var width:Float = 38; // (<- is it still fixed to get from font-defaults if this is MISSING ?)
	public var height:Float = 36;
	@global public var weight = 0.5; //0.49 <- more thick (only for ttfcompiled fonts)
}

class Main extends Application
{
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample()
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	var peoteView:PeoteView;
	
	var uvMap:UVmap; 
	
	public function startSample()
	{
		Load.image("assets/spiral8bpc.png", true, function(image:Image) {		
			new Font<MyFontStyle>("assets/hackfont/config.json").load( function(font:Font<MyFontStyle>) {
				allLoaded(image, font);
			});
		});
	}
	
	public function allLoaded(image:Image, font:Font<MyFontStyle>)
	{
		peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.GREY1);

		peoteView.addDisplay(display);
		
		var uvTexture = new Texture(image.width, image.height);
		uvTexture.setData(image);
			
		var fbTexture = new Texture(4096, 40, {smoothShrink: true});
		
		// set up Display for framebuffer
		var fontStyle = new MyFontStyle();
		
		var boxStyle = new BoxStyle(Color.BLACK);
		
		var uiDisplay = new PeoteUIDisplay(0, 0, 4096, 40);
		peoteView.setFramebuffer(uiDisplay, fbTexture);

		peoteView.addFramebufferDisplay(uiDisplay);
		// peoteView.addDisplay(uiDisplay);

		// ------------------- input TextLine ---------------------------
		
		var fontStyleInput = new MyFontStyle();
		fontStyleInput.color = Color.GREY5;
		//fontStyleInput.height = 30;
		//fontStyleInput.width = 20;
		
		var textConfig:TextConfig = {
			backgroundStyle:boxStyle,
			selectionStyle:BoxStyle.createById(1, Color.GREY3), // new ID for new Layer
			cursorStyle:BoxStyle.createById(2, Color.RED),       // new ID for new Layer
			//hAlign:HAlign.RIGHT,
			undoBufferSize: 30
		}
		
		var inputLine = new UITextLine<MyFontStyle>(2, 2, 0, 0, "Haxe", font, fontStyleInput, textConfig);
		uiDisplay.add(inputLine);
		inputLine.setInputFocus();

		PeoteUIDisplay.registerEvents(window);

			
		// -------------------------------------------------

		UVmap.init(display, uvTexture, fbTexture);
		uvMap = new UVmap(0, 0, 600, 600);
		
		uvMap.timeOffset(0.0, 1.0);
		UVmap.buffer.updateElement(uvMap);
		
		peoteView.start();
		
		
	}
	
	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// ----------------- MOUSE EVENTS ------------------------------
	
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseMove (x:Float, y:Float):Void {}	
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}

	var speed:Float = 1.0;
	override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {
		trace(deltaY, deltaY);
		if (deltaY > 0 &&speed < 3.0) speed += 0.01;
		else if (speed > 0.05) speed -= 0.01;
			
		uvMap.timeOffset(1.0-speed, speed);
		UVmap.buffer.updateElement(uvMap);
	}
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
	
}
