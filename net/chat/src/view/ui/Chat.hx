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
		
		// TODO: new peote-ui feature to set the input-focus automatically to some x or xy position!
		// inputLine.setInputFocusAt(0);

		// ----------------------------------------
		// custom keyboard-control via input2action
		// ----------------------------------------

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

	// logging function
	var isFirstMsg = true;
	// @:access(peote.ui.interactive.UITextPageT)
	public function say(s:String)
	{
		if (!isFirstMsg) s = "\n" + s;
		isFirstMsg = false;
		
		textPage.appendChars(s);

		// textPage.fontProgram.pageWrapLine(textPage.page, textPage.page.length, true);

		textPage.cursorPageEnd();
	}
}