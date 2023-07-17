package ui;

import lime.ui.Window;
import lime.ui.MouseCursor;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.*;
import peote.ui.style.*;
import peote.ui.style.interfaces.FontStyle;
import peote.ui.config.*;
import peote.ui.event.*;

// ------------------------------------------
// --- using a custom FontStyle here --------
// ------------------------------------------

@globalLineSpace // all pageLines using the same page.lineSpace (gap to next line into page)
@:structInit
class MyFontStyle implements FontStyle
{
	public var color:Color = Color.BLACK;
	//public var color:Color = Color.GREEN.setAlpha(0.5);
	public var width:Float = 10; // (<- is it still fixed to get from font-defaults if this is MISSING ?)
	public var height:Float = 18;
}

class UI 
{
	var window:Window;
	var onInit:Void->Void;
	
	var peoteView:PeoteView;
	var peoteUiDisplay:PeoteUIDisplay;
	
	public function new(window:Window, onInit:Void->Void) 
	{
		this.window = window;
		this.onInit = onInit;
		
		try new Font<MyFontStyle>("assets/hack_ascii.json").load( init )
		catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
	}

	public function init(font:Font<MyFontStyle>)
	{	
		peoteView = new PeoteView(window);
		peoteView.start();

		// ---- setting up some styles -----

		var boxStyle  = new BoxStyle(0x041144ff);
		
		var roundBorderStyle = RoundBorderStyle.createById(0);		
		
		var cursorStyle = BoxStyle.createById(1, Color.RED);
		var selectionStyle = BoxStyle.createById(2, Color.GREY3);
		
		var fontStyleHeader = MyFontStyle.createById(0);
		var fontStyleInput = MyFontStyle.createById(1);
		
		
		var textInputConfig:TextConfig = {
			backgroundStyle:boxStyle.copy(Color.GREY5),
			selectionStyle: selectionStyle,
			cursorStyle: cursorStyle
		}
		
		var sliderConfig:SliderConfig = {
			backgroundStyle: roundBorderStyle.copy(Color.GREY2),
			draggerStyle: roundBorderStyle.copy(Color.GREY3, Color.GREY2, 0.5),
			draggerSize:16,
			draggSpace:1,
		};
		
		// ---------------------------------------------------------
		// --- creating PeoteUIDisplay with some styles in Order ---
		// ---------------------------------------------------------
		
		peoteUiDisplay = new PeoteUIDisplay(0, 0, window.width, window.height, Color.BLACK,
			[roundBorderStyle, boxStyle, selectionStyle, fontStyleInput, fontStyleHeader, cursorStyle]
		);
		peoteView.addDisplay(peoteUiDisplay);

		
		// -----------------------------------------------------------
		// ---- creating an Area, header and Content-Area ------------
		// -----------------------------------------------------------
		
		var area = new UIArea(50, 50, 500, 500, {backgroundStyle:roundBorderStyle, resizeType:ResizeType.LEFT|ResizeType.BOTTOM_LEFT|ResizeType.BOTTOM, minWidth:200, minHeight:100} );
		peoteUiDisplay.add(area);
		
		// to let the area drag
		area.setDragArea(
			Std.int(-peoteUiDisplay.xOffset / peoteUiDisplay.xz),
			Std.int(-peoteUiDisplay.yOffset / peoteUiDisplay.yz),
			Std.int(peoteUiDisplay.width    / peoteUiDisplay.xz),
			Std.int(peoteUiDisplay.height   / peoteUiDisplay.yz)
		);
		
		// ---- header textline (starts also area-dragging) ----		
		
		var header = new UITextLine<MyFontStyle>(0, 0, 500, 0, 1, "Shadercode ...", font, fontStyleHeader, {backgroundStyle:roundBorderStyle, hAlign:HAlign.CENTER});
		header.onPointerDown = (_, e:PointerEvent)-> area.startDragging(e);
		header.onPointerUp = (_, e:PointerEvent)-> area.stopDragging(e);
		area.add(header);				
		
		
		// ---------------------------------------------------------
		// ------- inner UIArea for some scrollable content --------
		// ---------------------------------------------------------
		
		// ---- inner UIArea for scrolling content ----
		
		var content = new UIArea(2, header.height, area.width-20-2, area.height-header.height-20, boxStyle);
		area.add(content);
		
		// ---- add content ----
		
/*		var uiDisplay = new UIDisplay(20, 20, 200, 200, 1, Color.BLUE);
		uiDisplay.onPointerOver = (_,_)-> uiDisplay.display.color = Color.RED;
		uiDisplay.onPointerOut  = (_,_)-> uiDisplay.display.color = Color.BLUE;
		uiDisplay.onPointerDown = (_, e:PointerEvent)-> {
			uiDisplay.setDragArea(Std.int(content.x), Std.int(content.y), Std.int(content.width + uiDisplay.width - 10), Std.int(content.height + uiDisplay.height - 10));
			uiDisplay.startDragging(e);
		}
		uiDisplay.onPointerUp = (_, e:PointerEvent)-> uiDisplay.stopDragging(e);
		uiDisplay.onDrag = (_, x:Float, y:Float) -> {
			content.updateInnerSize();
			uiDisplay.maskByElement(content, true);
		}
		content.add(uiDisplay);
		
		var uiElement = new UIElement(220, 20, 200, 200, 0, roundBorderStyle);
		uiElement.onPointerDown = (_, e:PointerEvent)-> {
			uiElement.setDragArea(Std.int(content.x), Std.int(content.y), Std.int(content.width + uiElement.width - 10), Std.int(content.height + uiElement.height - 10));
			uiElement.startDragging(e);
		}
		uiElement.onPointerUp = (_, e:PointerEvent)-> uiElement.stopDragging(e);
		uiElement.onDrag = (_, x:Float, y:Float) -> {
			content.updateInnerSize();
			uiElement.maskByElement(content, true);
		}
		content.add(uiElement);		

		var inputPage = new UITextPage<MyFontStyle>(250, 300, 0, 0, 1, "input\ntext by\nUIText\tPage", font, fontStyleInput, textInputConfig);
		inputPage.onPointerDown = function(t:UITextPage<MyFontStyle>, e:PointerEvent) {
			t.setInputFocus(e);			
			t.startSelection(e);
		}
		inputPage.onPointerUp = function(t:UITextPage<MyFontStyle>, e:PointerEvent) {
			t.stopSelection(e);
		}
		inputPage.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			content.updateInnerSize();
			inputPage.maskByElement(content, true); // CHECK: need here ?
		}
		inputPage.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {
			content.updateInnerSize();
			inputPage.maskByElement(content, true); // CHECK: need here ?
		}
		content.add(inputPage);
		
*/				
		// ---------------------------------------------------------
		// ---- Sliders to scroll the innerArea ----		
		// ---------------------------------------------------------
		
		var hSlider = new UISlider(0, area.height-20, area.width-20, 20, sliderConfig);
		hSlider.onMouseWheel = (_, e:WheelEvent) -> hSlider.setWheelDelta( e.deltaY );
		//area.add(hSlider);		
		
		var vSlider = new UISlider(area.width-20, header.height, 20, area.height-header.height-20, sliderConfig);
		vSlider.onMouseWheel = (_, e:WheelEvent) -> vSlider.setWheelDelta( e.deltaY );
		area.add(vSlider);
		
		// bindings for sliders
		content.bindHSlider(hSlider);
		content.bindVSlider(vSlider);
		
		// ---------------------------------------------
		// -------- button to change the size ----------		
		// ---------------------------------------------
/*		
		var resizerBottomRight:UIElement = new UIElement(area.width - 19, area.height - 19, 18, 18, 2, roundBorderStyle.copy(Color.GREY3, Color.GREY1));	
		
		resizerBottomRight.onPointerDown = (_, e:PointerEvent)-> {
			resizerBottomRight.setDragArea(
				Std.int(area.x + 240),
				Std.int(area.y + 140),
				Std.int((peoteUiDisplay.width  - peoteUiDisplay.xOffset) / peoteUiDisplay.xz  - area.x - 240),
				Std.int((peoteUiDisplay.height - peoteUiDisplay.yOffset) / peoteUiDisplay.yz  - area.y - 140)
			);
			resizerBottomRight.startDragging(e);
		}
		resizerBottomRight.onPointerUp = (_, e:PointerEvent)-> resizerBottomRight.stopDragging(e);
		
		resizerBottomRight.onDrag = (_, x:Float, y:Float) -> {
			area.rightSize  = resizerBottomRight.right + 1;
			area.bottomSize = resizerBottomRight.bottom + 1;
			area.updateLayout();
		};
		resizerBottomRight.onPointerOver = (_,_)-> window.cursor = MouseCursor.RESIZE_NWSE;
		resizerBottomRight.onPointerOut  = (_,_)-> window.cursor = MouseCursor.DEFAULT;
		
		area.add(resizerBottomRight);
		
*/		
		// --- arrange header and sliders if area size is changing ---
		
		area.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			header.width = width;
			vSlider.right = area.right;
			content.rightSize = hSlider.rightSize = vSlider.left;
		}

		area.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {
			hSlider.bottom = area.bottom;
			content.bottomSize = vSlider.bottomSize = hSlider.top;
		}

		
		
		// ---------------------------------------------------------
	
		// TODO: make uiElement to switch between
		//uiDisplay.mouseEnabled = false;
		//uiDisplay.touchEnabled = false;
				
		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		PeoteUIDisplay.registerEvents(window);
		
		
		onInit();
	}
}