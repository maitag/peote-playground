package ui;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

import peote.ui.interactive.*;
import peote.ui.config.*;
import peote.ui.style.*;


class LogArea extends UIArea
{
	public var textPage:TextPage;

	public function new()
	{
		// -----------------------------------------------------------
		// ---- creating an Area, header and Content-Area ------------
		// -----------------------------------------------------------
		
		var sliderSize:Int = 16;
		var headerSize:Int = 20;
		var gap:Int = 3;
		
		super(0, 450, 650, 150, {backgroundStyle:Ui.styleBG, resizeType:ResizeType.ALL, minWidth:200, minHeight:100});		
		
		// --------------------------
		// ---- header textline -----		
		// --------------------------
		
		var header = new UITextPageT(gap, gap,
			width - gap - gap, headerSize, 
			"=== Logger ===", Ui.font, Ui.fontStyleFG, { backgroundStyle:Ui.styleBG, hAlign:HAlign.CENTER }
		);
		// start/stop area-dragging
		header.onPointerDown = (_, e:PointerEvent)-> startDragging(e);
		header.onPointerUp = (_, e:PointerEvent)-> stopDragging(e);
		add(header);
		
		
		// --------------------------
		// ------- edit area --------
		// --------------------------

		var textConfig:TextConfig = {
			backgroundStyle:Ui.styleBG,
			selectionStyle: Ui.selectionStyle,
			cursorStyle: Ui.cursorStyle,
			textSpace: { left:3, right:1, top:1, bottom:1 },
			undoBufferSize:100
		}
		
		textPage = new UITextPage<UiFontStyle>(gap, headerSize + gap + 1,
			width - sliderSize - gap - gap - 1,
			height - headerSize - sliderSize - 2 - gap - gap,
			"", Ui.font, Ui.fontStyleBG, textConfig
		);
		
		textPage.onPointerDown = function(t, e) {
			t.startSelection(e);
		}
		
		textPage.onPointerUp = function(t, e) {
			t.stopSelection(e);
		}
		add(textPage);
		
				
		// ------------------------------------
		// ---- sliders to scroll textPage ----		
		// ------------------------------------
		
		var sliderConfig:SliderConfig = {
			backgroundStyle: Ui.styleBG.copy(Color.BLACK, Color.BLACK, 0),
			draggerStyle: Ui.styleBG.copy(0x1F0000ff, 0x1F0000ff, 0),
			draggerSize:sliderSize - 2,
			draggSpace:1,
		};
		
		var hSlider = new UISlider(gap, height-sliderSize-gap, textPage.width, sliderSize, sliderConfig);
		hSlider.onMouseWheel = (_, e:WheelEvent) -> hSlider.setWheelDelta( e.deltaY );
		add(hSlider);		
		
		var vSlider = new UISlider(width-sliderSize-gap, headerSize + gap + 1, sliderSize, textPage.height, sliderConfig);
		vSlider.onMouseWheel = (_, e:WheelEvent) -> vSlider.setWheelDelta( e.deltaY );
		add(vSlider);
				
		// bind textPage to sliders
		textPage.bindHSlider(hSlider);
		textPage.bindVSlider(vSlider);

				
		// ------------------------------------
		// --------- RESIZE HANDLING ----------		
		// ------------------------------------
		
		this.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			header.width = width - gap - gap;
			vSlider.right = right - gap;
			textPage.rightSize = vSlider.left - 1;
			hSlider.width = textPage.width;
		}

		this.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {
			hSlider.bottom = bottom - gap;
			textPage.bottomSize = hSlider.top - 1;
			vSlider.height = textPage.height;
		}


	}	

	public function log(s:String, clear = false) {
		s += "\n";
		if (clear) textPage.text = s;
		else textPage.appendChars(s);
		textPage.cursorPageEnd();
	}
}
