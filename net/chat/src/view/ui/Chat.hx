package view.ui;

class Chat extends UIArea implements ParentElement {

	var onInput:String->Void;
	
	public function new(x:Int, y:Int, width:Int, height:Int, onInput:String->Void)
	{
		this.onInput = onInput;
		super(x, y, width, height, 0, Ui.chatAreaConfig);		
	}

	var textPage:TextPage;
	var inputLine:TextLine;
	var slider:UISlider;

	override function onAddUIElementToDisplay()
	{
		super.onAddUIElementToDisplay();

		// -----------------------------------------------------------
		
		var sliderSize:Int = 16;
		var inputSize:Int = 30;
		var gap:Int = 3;

		// ---- chat OUTPUT  ----

		textPage = new TextPage(gap, gap + 1,
			width - sliderSize - gap - gap - 1,
			height - inputSize - 2 - gap - gap,
			"Welcome to chat sample into peote playground \\o/\n\n",
			Ui.font, Ui.chatFontStyle, Ui.chatTextConfig
		);
		textPage.onPointerDown = function(t:TextPage, e:PointerEvent) { t.startSelection(e); }
		textPage.onPointerUp = function(t:TextPage, e:PointerEvent) { t.stopSelection(e); }
		add(textPage);

		// --- chat INPUT ----

		inputLine = new TextLine(gap, height-inputSize, width - gap - gap, 20, 0, "", Ui.font, Ui.chatFontStyle, Ui.chatInputTextConfig);
		inputLine.onPointerDown = function(t:TextLine, e:PointerEvent) { t.setInputFocus(e); t.startSelection(e); }
		inputLine.onPointerUp = function(t:TextLine, e:PointerEvent) { t.stopSelection(e); }
		add(inputLine);
		
		// --- custom keyboard-control via input2action ---

		var actionConfig:ActionConfig = [
			{ action: "enter" , keyboard: [KeyCode.RETURN, KeyCode.NUMPAD_ENTER], single:true },
		];
		actionConfig.add(InputTextLine.actionConfig, false);
		
		var actionMap:ActionMap = [
			// WHY the "()->{}" syntax only works if have only one expression inside the "{}" ???
			// maybe haxe-GLITCH :) ???
			// "enter" => { action:(_, _) -> { onInput(inputLine.text); inputLine.text = ""; }, repeatKeyboardDefault:false },			
			"enter" => { action: function(_,_) {
				onInput(inputLine.text);
				inputLine.text = "";
				inputLine.setXOffset(0);
				inputLine.setCursor(0);
			},
			repeatKeyboardDefault:false },			
		];
		actionMap.add(InputTextLine.actionMap, false);

		var input2Action:Input2Action = new Input2Action();
		input2Action.addKeyboard(new KeyboardAction(actionConfig, actionMap));
				
		inputLine.input2Action = input2Action;


		// ------------------------------------
		// ---- sliders to scroll textPage ----		
		// ------------------------------------		
		
		var slider = new UISlider(width-sliderSize-gap, gap + 1, sliderSize, textPage.height, Ui.chatSliderConfig);
		
		slider.onMouseWheel = (_, e:WheelEvent) -> slider.setDelta( e.deltaY * 32 );
		textPage.onMouseWheel = (_, e:WheelEvent) -> slider.setDelta( e.deltaY * 32 );
		
		add(slider);

		// bind textPage to sliders
		textPage.bindVSlider(slider);



		// ------------------------------------
		// --------- RESIZE HANDLING ----------		
		// ------------------------------------
		
		this.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {

			slider.right = last_x + width - gap;

			textPage.width += deltaWidth;
			textPage.updateLayout();

			inputLine.width += deltaWidth;
			inputLine.updateLayout();
		}

		this.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {

			slider.height += deltaHeight;

			textPage.height += deltaHeight;
			textPage.updateLayout();

			inputLine.y += deltaHeight;
			inputLine.updateLayout();

		}

	}

	public function setInputFocus() inputLine.setInputFocusAt(0);

	// ----- C H A T (^_^) o u t -----

	var lastNick = "";
	
	public function say(s:String, ?nick:String)
	{	
		// remove from top
		if (textPage.length > 5000) textPage.deleteChars(0, 50, 0, 100000);

		textPage.appendChars("\n");
		if (nick == null || lastNick == nick) textPage.appendChars(s);
		else {
			lastNick = nick;
			textPage.appendChars(nick + ": ", Ui.chatNameFontStyle);
			textPage.appendChars(s);
		}

		// little hâck only here until not interated into peote-ui (sry~_->)
		textPage.fontProgram.pageWrapLine(textPage.page, textPage.length-1, true, false);
		
		textPage.setCursorLine(textPage.length-1);
		textPage.updateLayout();
	}
}