package view.ui;

class NameInput extends UIArea implements ParentElement {

	// callbacks
	var onConnect:String->Void;


	public function new(x:Int, y:Int, width:Int, height:Int, onConnect:String->Void)
	{
		this.onConnect = onConnect;

		super(x, y, width, height, 0, Ui.nameAreaConfig);		
	}

	var inputLine = TextLine;

	override function onAddUIElementToDisplay()
	{
		super.onAddUIElementToDisplay();

		// ---- enter name ----
		add(new TextLine(20, 30, 0, 30, 1, "nick name:", Ui.font, Ui.nameLabelFontStyle, Ui.nameLabelTextConfig));


		var inputLine = new TextLine(120, 30, 100, 30, 1, "", Ui.font, Ui.nameInputFontStyle, Ui.nameInputTextConfig);
		inputLine.onPointerDown = function(t:TextLine, e:PointerEvent) { t.setInputFocus(e); t.startSelection(e); }
		inputLine.onPointerUp = function(t:TextLine, e:PointerEvent) { t.stopSelection(e); }
		add(inputLine);
		
		// custom keyboard-control via input2action
		var actionConfig:ActionConfig = [
			{ action: "enter" , keyboard: [KeyCode.RETURN, KeyCode.NUMPAD_ENTER], single:true },
		];
		actionConfig.add(InputTextLine.actionConfig, false);
		
		var actionMap:ActionMap = [
			"enter" => { action:(_, _) -> { onConnect(inputLine.text); }, repeatKeyboardDefault:false },			
		];
		actionMap.add(InputTextLine.actionMap, false);

		var input2Action:Input2Action = new Input2Action();
		input2Action.addKeyboard(new KeyboardAction(actionConfig, actionMap));
				
		inputLine.input2Action = input2Action;

		// --- connect button -----

		// ...


		// ------------------------------------
		// --------- RESIZE HANDLING ----------		
		// ------------------------------------
		
		this.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
		}

		this.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {

		}

	}

}