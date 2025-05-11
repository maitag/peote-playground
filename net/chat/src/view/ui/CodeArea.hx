package ui;

import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

import peote.ui.interactive.*;
import peote.ui.config.*;
import peote.ui.style.*;

import script.HscriptFarm;
import script.HscriptObject;
import script.HscriptFunction;

class CodeArea extends UIArea
{
	public var onRun:Void->Void;
	public var textPage:UITextPage<UiFontStyle>;
	public var header:UITextLine<UiFontStyle>;

	public function new(onRun:Void->Void)
	{
		this.onRun = onRun;

		// -----------------------------------------------------------
		// ---- creating an Area, header and Content-Area ------------
		// -----------------------------------------------------------
		
		super(0, 50, 650, 400, {backgroundStyle:Ui.styleBG, resizeType:ResizeType.ALL, minWidth:200, minHeight:100});
		
	}

	override function onAddUIElementToDisplay()
	{
		super.onAddUIElementToDisplay();
		
		if (childs.length > 0) return;
		// add only at the first time

		var sliderSize:Int = 16;
		var headerSize:Int = 20;
		var gap:Int = 3;
		
		
		// --------------------------
		// ---- header textline -----		
		// --------------------------
		
		header = new UITextLine<UiFontStyle>(gap, gap,
			0, headerSize, 
			"funky", Ui.font, Ui.fontStyleFG, { backgroundStyle:Ui.styleBG }
		);
		// start/stop area-dragging
		header.onPointerDown = (_, e:PointerEvent)-> startDragging(e);
		header.onPointerUp = (_, e:PointerEvent)-> stopDragging(e);
		add(header);
		
		var runButton = new UITextLine<UiFontStyle>(0, gap,
			0, headerSize, 
			"run", Ui.font, Ui.fontStyleFG, { backgroundStyle:Ui.styleBG }
		);

		runButton.onPointerClick = (_,_) -> {
			onRun();
		}
		
		var runButtonOverStyle = Ui.styleBG.copy();
		runButtonOverStyle.color = Color.GREEN1;

		runButton.onPointerOver = (_,_) -> runButton.backgroundStyle = runButtonOverStyle;
		runButton.onPointerOut = (_,_) -> runButton.backgroundStyle = Ui.styleBG;
		
		add(runButton);
		runButton.right = right - gap;
		
		// --------------------------
		// ------- edit area --------
		// --------------------------

		var textConfig:TextConfig = {
			backgroundStyle:Ui.styleBG,
			selectionStyle: Ui.selectionStyle,
			cursorStyle: Ui.cursorStyle,
			textSpace: { left:5, right:5, top:3, bottom:3 },
			undoBufferSize:100
		}
		
		textPage = new UITextPage<UiFontStyle>(gap, headerSize + gap + 1,
			width - sliderSize - gap - gap - 1,
			height - headerSize - sliderSize - 2 - gap - gap,
			"",
			Ui.font, Ui.fontStyleBG, textConfig
		);
		
		textPage.onPointerDown = function(t, e) {
			t.setInputFocus(e);			
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
		var vSlider = new UISlider(width-sliderSize-gap, headerSize + gap + 1, sliderSize, textPage.height, sliderConfig);

		hSlider.onMouseWheel = (_, e:WheelEvent) -> hSlider.setDelta( e.deltaY * 18);
		
		// move hSlider in or outside of area to show/hide
		var hSliderIsVisible = true;
		hSlider.onChange = (_,_,_) -> {
			if (hSlider.draggerLengthPercent < 1.0) {
				if (! hSliderIsVisible) {
					// trace("show hSlider");
					hSlider.bottom = bottom - gap;
					textPage.bottomSize = hSlider.top - 1;
					vSlider.height = textPage.height;
					updateLayout();
					hSliderIsVisible = true;
				}
			}
			else if (hSliderIsVisible) {
				// trace("hide hSlider");
				hSlider.top = bottom;
				textPage.bottomSize = bottom - 3;
				vSlider.height = textPage.height;
				updateLayout();
				hSliderIsVisible = false;
			}
		};

		if (textPage.textWidth <= textPage.width - textPage.leftSpace - textPage.rightSpace) {
			hSlider.top = bottom;
			textPage.bottomSize = bottom - 3;
			vSlider.height = textPage.height;
			updateLayout();
			hSliderIsVisible = false;
		}
		add(hSlider);		

		vSlider.onMouseWheel = (_, e:WheelEvent) -> vSlider.setDelta( e.deltaY * 32 );
		textPage.onMouseWheel = (_, e:WheelEvent) -> vSlider.setDelta( e.deltaY * 32 );
		
		// move vSlider in or outside of area to show/hide
		var vSliderIsVisible = true;
		vSlider.onChange = (_,_,_) -> {
			if (vSlider.draggerLengthPercent < 1.0) {
				if (! vSliderIsVisible) {
					// trace("show vSlider");
					vSlider.right = right - gap;
					textPage.rightSize = vSlider.left - 1;
					hSlider.width = textPage.width;
					updateLayout();
					vSliderIsVisible = true;
				}
			}
			else if (vSliderIsVisible) {
				// trace("hide vSlider");
				vSlider.left = right;
				textPage.rightSize = right - 3;
				hSlider.width = textPage.width;
				updateLayout();
				vSliderIsVisible = false;
			}
		};
		
		if (textPage.textHeight <= textPage.height - textPage.topSpace -textPage.bottomSpace) {
			vSlider.left = right;
			textPage.rightSize = right - 3;
			hSlider.width = textPage.width;
			updateLayout();
			vSliderIsVisible = false;
		}
		add(vSlider);
				
		// bind textPage to sliders
		textPage.bindHSlider(hSlider);
		textPage.bindVSlider(vSlider);

		

		// ------------------------------------
		// --------- RESIZE HANDLING ----------		
		// ------------------------------------
		
		this.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			header.width = width - gap - gap;

			if (hSliderIsVisible) textPage.bottomSize = hSlider.top - 1;
			else textPage.bottomSize = bottom - 3;
			vSlider.height = textPage.height;

			if (vSliderIsVisible) {
				vSlider.right = right - gap;
				textPage.rightSize = vSlider.left - 1;
			}
			else {
				vSlider.left = right;
				textPage.rightSize = right - 3;
			}
			hSlider.width = textPage.width;

			runButton.right = right - gap;
		}

		this.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {

			if (hSliderIsVisible) {
				hSlider.bottom = bottom - gap;
				textPage.bottomSize = hSlider.top - 1;
			}
			else {
				hSlider.top = bottom;
				textPage.bottomSize = bottom - 3;
			}
			vSlider.height = textPage.height;
			
			if (vSliderIsVisible) textPage.rightSize = vSlider.left - 1;
			else textPage.rightSize = right - 3;
			hSlider.width = textPage.width;

			
		}

	}	

}
