package view.ui;

class Log extends UIArea implements ParentElement
{
	public var textPage:TextPage;

	public var headerText:String = null;

	public function new(x:Int, y:Int, width:Int, height:Int, ?headerText:String)
	{
		this.headerText = headerText;
		super(x, y, width, height, 0, Ui.logAreaConfig);		
	}

	override function onAddUIElementToDisplay()
	{
		super.onAddUIElementToDisplay();		
		if (childs.length > 0) return; // add only at the first time		
		// ---------------------------------------------------------
		
		var sliderSize:Int = 16;
		var headerSize:Int = 0;
		var gap:Int = 3;
		
		// --------------------------
		// ---- header textline -----		
		// --------------------------
		var header:TextLine = null;

		if (headerText != null)	{
			headerSize = 20;
			
			header = new TextLine(gap, gap,
				width - gap - gap, headerSize, 
				headerText, Ui.font, Ui.logFontStyle, Ui.logTextConfig 
			);
			// start/stop area-dragging
			header.onPointerDown = (_, e:PointerEvent)-> startDragging(e);
			header.onPointerUp = (_, e:PointerEvent)-> stopDragging(e);
			add(header);
		}
		
		// -------------------------
		// ------- TextPage --------
		// -------------------------
		
		textPage = new TextPage(gap, headerSize + gap + 1,
			width - sliderSize - gap - gap - 1,
			height - headerSize - sliderSize - 2 - gap - gap,
			"", Ui.font, Ui.logFontStyle, Ui.logTextConfig
		);
		
		textPage.onPointerDown = function(t, e) {
			// t.setInputFocus(e);
			t.startSelection(e);
		}
		
		textPage.onPointerUp = function(t, e) {
			t.stopSelection(e);
			t.copyToClipboard();
		}
		add(textPage);
				
				
		// ------------------------------------
		// ---- sliders to scroll textPage ----		
		// ------------------------------------		
		
		var hSlider = new UISlider(gap, height-sliderSize-gap, textPage.width, sliderSize, Ui.logSliderConfig);
		var vSlider = new UISlider(width-sliderSize-gap, headerSize + gap + 1, sliderSize, textPage.height, Ui.logSliderConfig);
		
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
			if (header != null) header.width = width - gap - gap;
			
			if (hSliderIsVisible) textPage.bottomSize = hSlider.top - 1;
			else textPage.bottomSize = last_y + height - 3;
			vSlider.height = textPage.height;

			if (vSliderIsVisible) {
				vSlider.right = last_x + width - gap; // using last_x here to avoid glitch while change the y position (not update) and resizing afterwards (or use deltaWidth instead!)
				textPage.rightSize = vSlider.left - 1;
			}
			else {
				vSlider.left = last_x + width;
				textPage.rightSize = last_x + width - 3;
			}
			hSlider.width = textPage.width;
		}

		this.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {
			if (hSliderIsVisible) {
				hSlider.bottom = last_y + height - gap; // using last_y here to avoid glitch while change the y position (not update) and resizing afterwards 
				textPage.bottomSize = hSlider.top - 1;
			}
			else {
				hSlider.top = last_y + height;
				textPage.bottomSize = last_y + height - 3;
			}
			vSlider.height = textPage.height;
			
			if (vSliderIsVisible) textPage.rightSize = vSlider.left - 1;
			else textPage.rightSize = last_x + width - 3;
			hSlider.width = textPage.width;
		}

	}


	// logging function
	
	var isFirstLog = true;
	public function say(s:String, clear = false)
	{
		if (clear) {
			textPage.text = s;
		}
		else {
			// remove from top
			if (textPage.length > 5000) textPage.deleteChars(0, 50, 0, 100000);

			if (!isFirstLog) s = "\n" + s;
			textPage.appendChars(s);
		}
		isFirstLog = false;

		textPage.setCursorLine(textPage.length-1);
	}
}
