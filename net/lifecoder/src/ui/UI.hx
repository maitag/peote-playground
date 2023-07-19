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
import peote.ui.config.*;
import peote.ui.event.*;


class UI 
{
	public var editor:UITextPage<FontStyleEdit>;
	
	var window:Window;
	var onInit:Void->Void;
	
	var peoteView:PeoteView;
	var peoteUiDisplay:PeoteUIDisplay;
		
	var boxStyle:BoxStyle;		
	var roundBorderStyle:RoundBorderStyle;		
	
	var cursorStyle:BoxStyle;
	var selectionStyle:BoxStyle;
	
	var fontStyleHeader:FontStyleEdit;
	var fontStyleInput:FontStyleEdit;
	
	var font:Font<FontStyleEdit>;

	
	public function new(window:Window, onInit:Void->Void) 
	{
		this.window = window;
		this.onInit = onInit;
		
		try new Font<FontStyleEdit>("assets/hack_ascii.json").load( init )
		catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
	}

	public function init(font:Font<FontStyleEdit>)
	{
		this.font = font;
		peoteView = new PeoteView(window);

		// ---- setting up some styles -----

		boxStyle  = new BoxStyle(0x041144ff);		
		roundBorderStyle = RoundBorderStyle.createById(0);		
		
		cursorStyle = BoxStyle.createById(1, Color.RED);
		selectionStyle = BoxStyle.createById(2, Color.GREY3);
		
		fontStyleHeader = FontStyleEdit.createById(0);
		fontStyleInput = FontStyleEdit.createById(1);
		
		
		// --------------------------------------------------------
		// --- creating PeoteUIDisplay with the styles in Order ---
		// --------------------------------------------------------
		
		peoteUiDisplay = new PeoteUIDisplay(0, 0, window.width, window.height, Color.BLACK,
			[roundBorderStyle, boxStyle, selectionStyle, fontStyleInput, fontStyleHeader, cursorStyle]
		);
		peoteView.addDisplay(peoteUiDisplay);
		
		
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
	
	// ---------------------------------------------------------
	// ------------- create Text area for input or output ------
	// ---------------------------------------------------------
	
	public function createCodeEditor(editMode = false, ?onInsertText:Int->Int->String->Void, ?onDeleteText:Int->Int->Int->Int->Void)
	{
		var textConfig:TextConfig = {
			backgroundStyle:boxStyle.copy(Color.GREY5),
			selectionStyle: selectionStyle,
			cursorStyle: cursorStyle,
			undoBufferSize: ((editMode) ? 100 : 0)
		}
		
		var sliderConfig:SliderConfig = {
			backgroundStyle: roundBorderStyle.copy(Color.GREY2),
			draggerStyle: roundBorderStyle.copy(Color.GREY3, Color.GREY2, 0.5),
			draggerSize:16,
			draggSpace:1,
		};
		
		// -----------------------------------------------------------
		// ---- creating an Area, header and Content-Area ------------
		// -----------------------------------------------------------
		
		var sliderSize:Int = 20;
		var headerSize:Int = 20;
		var gap:Int = 3;
		
		var area = new UIArea(0, 0, 400, 400, {backgroundStyle:roundBorderStyle, resizeType:ResizeType.ALL, minWidth:200, minHeight:100});
		#if testlocal
		if (!editMode) area.x = 400;
		#end
		// to let the area drag
		area.setDragArea(0, 0, peoteUiDisplay.width, peoteUiDisplay.height);
		peoteUiDisplay.add(area);
		
		
		// --------------------------
		// ------ header area -------		
		// --------------------------
		
		var headerArea = new UIArea(gap, gap, area.width - gap - gap, headerSize, {backgroundStyle:roundBorderStyle});
		// start/stop area-dragging
		headerArea.onPointerDown = (_, e:PointerEvent)-> area.startDragging(e);
		headerArea.onPointerUp = (_, e:PointerEvent)-> area.stopDragging(e);
		area.add(headerArea);
		
		if (editMode) {
			var runButton = new UITextLine<FontStyleEdit>(0, 0, 0, 20, 
				"Run", font, fontStyleHeader, { backgroundStyle:roundBorderStyle, textSpace:{left:7,right:7} }
			);
			headerArea.add(runButton);
			runButton.right = headerArea.right;
			runButton.updateLayout();
			
			headerArea.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
				runButton.right = headerArea.right;
			}
		}
		

		// --------------------------
		// ------- edit area --------
		// --------------------------
		
		editor = new UITextPage<FontStyleEdit>(gap, headerSize + gap + 1,
			area.width - sliderSize - gap - gap - 1,
			area.height - headerSize - sliderSize - 2 - gap - gap,
			"",
			font, fontStyleInput, textConfig
		);
		
		if (editMode) {
			editor.onPointerDown = function(t, e) {
				t.setInputFocus(e);			
				t.startSelection(e);
			}		
			editor.onPointerUp = function(t, e) {
				t.stopSelection(e);
			}
			editor.onInsertText = function(t:UITextPage<FontStyleEdit>, fromLine:Int, toLine:Int, fromPos:Int, toPos:Int, chars:String)  {
				onInsertText(fromLine, fromPos, chars );
			}
			editor.onDeleteText = function(t:UITextPage<FontStyleEdit>, fromLine:Int, toLine:Int, fromPos:Int, toPos:Int, chars:String)  {
				onDeleteText(fromLine, toLine, fromPos, toPos );
			}
		} 
		else {
			editor.cursorShow();
		}
		
		area.add(editor);
		
		
		
		// ------------------------------------
		// ---- sliders to scroll editor ----		
		// ------------------------------------
		
		var hSlider = new UISlider(gap, area.height-sliderSize-gap, editor.width, sliderSize, sliderConfig);
		hSlider.onMouseWheel = (_, e:WheelEvent) -> hSlider.setWheelDelta( e.deltaY );
		area.add(hSlider);		
		
		var vSlider = new UISlider(area.width-sliderSize-gap, headerSize + gap + 1, sliderSize, editor.height, sliderConfig);
		vSlider.onMouseWheel = (_, e:WheelEvent) -> vSlider.setWheelDelta( e.deltaY );
		area.add(vSlider);
				
		// bind editor to sliders
		editor.bindHSlider(hSlider);
		editor.bindVSlider(vSlider);

				
		// --- arrange header and sliders if area size is changing ---
		
		area.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			headerArea.width = width - gap - gap;
			vSlider.right = area.right - gap;
			editor.rightSize = vSlider.left - 1;
			hSlider.width = editor.width;
		}

		area.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {
			hSlider.bottom = area.bottom - gap;
			editor.bottomSize = hSlider.top - 1;
			vSlider.height = editor.height;
		}
		
	}
	
	public function insertCode(fromLine:Int, fromPos:Int, chars:String):Void {
		//editor.insertChars(chars, fromLine, fromPos);
		//editor.updateLayout();
		editor.setCursorAndLine(fromPos, fromLine);
		editor.textInput(chars);
	}
	
	@:access(peote.ui.interactive)
	public function deleteCode(fromLine:Int, toLine:Int, fromPos:Int, toPos:Int):Void {
		editor.setOldTextSize();
		editor.deleteChars(fromLine, toLine, fromPos, toPos);
		editor.setCursorAndLine(fromPos, fromLine, false);
		editor.updateTextOnly(true);		
	}
	
	
}