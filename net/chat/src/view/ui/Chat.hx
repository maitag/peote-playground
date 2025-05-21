package view.ui;

class Chat extends UIArea implements ParentElement {

	var onInput:String->Void;
	
	public function new(x:Int, y:Int, width:Int, height:Int, onInput:String->Void)
	{
		this.onInput = onInput;
		super(x, y, width, height, 0, Ui.logAreaConfig);		
	}

	var chatPage = TextPage;
	var inputLine = TextLine;

	override function onAddUIElementToDisplay()
	{
		super.onAddUIElementToDisplay();

		// ---- chat OUTPUT  ----

		var chatPage = new TextPage(0, 0, 200, height-30, 1, "chat\nOUTPUT\nhere\n\n....\n......", Ui.font, Ui.logAreaFontStyle, Ui.logAreaTextConfig);
		chatPage.onPointerDown = function(t:TextPage, e:PointerEvent) { t.startSelection(e); }
		chatPage.onPointerUp = function(t:TextPage, e:PointerEvent) { t.stopSelection(e); }
		add(chatPage);

		// --- chat INPUT ----

		var inputLine = new TextLine(0, height-30, width, 20, 1, "INPUTLINE", Ui.font, Ui.logAreaFontStyle, Ui.logAreaTextConfig);
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
		}

		this.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {

			inputLine.y += deltaHeight;
			inputLine.updateLayout();

		}

	}

}