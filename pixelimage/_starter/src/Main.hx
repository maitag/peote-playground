package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.UITextLine;
import peote.ui.interactive.UITextPage;
import peote.ui.event.PointerEvent;
import peote.ui.style.BoxStyle;
import peote.ui.style.RoundBorderStyle;
import peote.ui.style.TextStyle;
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
	public var width:Float = 18; // (<- is it still fixed to get from font-defaults if this is MISSING ?)
	public var height:Float = 20;
	@global public var weight = 0.5; //0.49 <- more thick (only for ttfcompiled fonts)
}

// -----------------------------------
// -------- main code starts ---------
// -----------------------------------

class Main extends Application
{
	var peoteView:PeoteView;
	var uiDisplay:PeoteUIDisplay;
	
	
	// L I M E - initializing
	
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	// ---------------------------------------------------------------------------
	// --- before starting PeoteUIDisplay, it have to load the fonts at first  ---
	// ---------------------------------------------------------------------------

	public function startSample(window:Window)
	{
		new Font<MyFontStyle>("assets/fonts/packed/hack/config.json").load( onFontLoaded );
	}
	
	// ----------------------------------------------
	// ------ OK, we are READY at now (^_^)  --------
	// ----------------------------------------------

	public function onFontLoaded(font:Font<MyFontStyle>) // don'T forget argument-type here !
	{					
		peoteView = new PeoteView(window);
		uiDisplay = new PeoteUIDisplay(20, 20, 1768, 1200, Color.BLACK + 0x0a030100);
		peoteView.addDisplay(uiDisplay);		
		
		
		// ----------------------
		// ------ Styles --------
		// ----------------------
				
		var fontStyle = new MyFontStyle();		
		var fontStyleInput = new MyFontStyle();
		fontStyleInput.color = Color.GREY5;
		
		var boxStyle  = new BoxStyle(Color.BLACK);		
		var roundBorderStyle = new RoundBorderStyle(Color.GREEN);

		var textStyle:TextStyle = {
			backgroundStyle:boxStyle,
			selectionStyle:BoxStyle.createById(1, Color.GREY3),
			cursorStyle:BoxStyle.createById(2, Color.RED)
		}
		
		
		// ----------------------
		// ------ OUTPUT --------
		// ----------------------
		

		// ... need help by half and nanji here ;:)
		
		
		
	
		
		// ----------------------
		// ------ BUTTON --------
		// ----------------------
		
		var button = new UITextLine<MyFontStyle>(0, 300, {width:200}, "generate", font, fontStyleInput, textStyle);
		
		// todo: event to send input to output ! (can do that later!.. np ^_^)
		
		uiDisplay.add(button);
		
				
		// ----------------------
		// ------- INPUT --------
		// ----------------------
				
		var input = new UITextPage<MyFontStyle>(0, 325,

// nanji-test-c o d e		
'<EllipseShape 
	top="100" 
	width="200" 
	height="50" 
	strokeColor="0xFF0000" strokeWidth="1" 
	fill="0xFF00FF00">
</EllipseShape>',


			font, fontStyle, textStyle
		);

		input.onPointerDown = function(t:UITextPage<MyFontStyle>, e:PointerEvent) {
			t.setInputFocus(e);
			t.startSelection(e);
		}
		input.onPointerUp = function(t:UITextPage<MyFontStyle>, e:PointerEvent) {
			t.stopSelection(e);
		}
		uiDisplay.add(input);
		
		// -----------------------------------
				
		PeoteUIDisplay.registerEvents(window);
	}
	
}
