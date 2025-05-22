package view.ui;

class Chat extends UIArea implements ParentElement {

	var onInput:String->Void;
	
	public function new(x:Int, y:Int, width:Int, height:Int, onInput:String->Void)
	{
		this.onInput = onInput;
		super(x, y, width, height, 0, Ui.logAreaConfig);		
	}

	var textPage:TextPage;
	var inputLine:TextLine;

	override function onAddUIElementToDisplay()
	{
		super.onAddUIElementToDisplay();

		// ---- chat OUTPUT  ----

		textPage = new TextPage(0, 0, width, height-30, 1, "Welcome to chat sample into peote playground \\o/\n\n", Ui.font, Ui.logAreaFontStyle, Ui.logAreaTextConfig);
		textPage.onPointerDown = function(t:TextPage, e:PointerEvent) { t.startSelection(e); }
		textPage.onPointerUp = function(t:TextPage, e:PointerEvent) { t.stopSelection(e); }
		add(textPage);

		// --- chat INPUT ----

		inputLine = new TextLine(0, height-30, width, 20, 1, "INPUTLINE", Ui.font, Ui.logAreaFontStyle, Ui.logAreaTextConfig);
		inputLine.onPointerDown = function(t:TextLine, e:PointerEvent) { t.setInputFocus(e); t.startSelection(e); }
		inputLine.onPointerUp = function(t:TextLine, e:PointerEvent) { t.stopSelection(e); }
		add(inputLine);
		
		// custom keyboard-control via input2action

		var actionConfig:ActionConfig = [
			{ action: "enter" , keyboard: [KeyCode.RETURN, KeyCode.NUMPAD_ENTER], single:true },
		];
		actionConfig.add(InputTextLine.actionConfig, false);
		
		var actionMap:ActionMap = [
			"enter" => { action:(_, _) -> { onInput(inputLine.text);	}, repeatKeyboardDefault:false },			
		];
		actionMap.add(InputTextLine.actionMap, false);

		var input2Action:Input2Action = new Input2Action();
		input2Action.addKeyboard(new KeyboardAction(actionConfig, actionMap));
				
		inputLine.input2Action = input2Action;




		// ------------------------------------
		// --------- RESIZE HANDLING ----------		
		// ------------------------------------
		
		this.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			textPage.width += deltaWidth;
			textPage.updateLayout();

			inputLine.width += deltaWidth;
			inputLine.updateLayout();
		}

		this.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {

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