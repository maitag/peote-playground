package view.ui;

class NameInput extends UIArea implements ParentElement {

	// callbacks
	var onConnect:String->Void;

	var connectButton:TextLine;
	var inputLine:TextLine;

	public function new(x:Int, y:Int, width:Int, height:Int, onConnect:String->Void)
	{
		this.onConnect = onConnect;
		super(x, y, width, height, 0, Ui.nameAreaConfig);		
	}

	override function onAddUIElementToDisplay()
	{
		super.onAddUIElementToDisplay();
		if (childs.length > 0) return; // add only at the first time
		// ---------------------------------------------------------

		// --- connect button -----
		connectButton = new TextLine(346, 32, 0, 26, 0, "enter", Ui.font, Ui.nameButtonFontStyle, Ui.nameButtonTextConfig);
		connectButton.onPointerDown = (_,_) -> enter(inputLine.text);

		// ---- enter name ----
		add(new TextLine(20, 30, 0, 30, 1, "nick name:", Ui.font, Ui.nameLabelFontStyle, Ui.nameLabelTextConfig));

		inputLine = new TextLine(120, 32, 218, 26, 0, "", Ui.font, Ui.nameInputFontStyle, Ui.nameInputTextConfig);
		inputLine.onPointerDown = function(t:TextLine, e:PointerEvent) { t.setInputFocus(e); t.startSelection(e); }
		inputLine.onPointerUp = function(t:TextLine, e:PointerEvent) { t.stopSelection(e); }
		// restrict the chars what is allowed for input
		inputLine.restrictedChars = " a-zA-Z0-9+-*~/\\^.,;§$%&=?_#\"'`[](){}%&<>|";
		// inputLine.restrictedChars = "a-zA-Z0-9+-*~/\\^.,;§$%&=?_#\"'`[](){}%&<>|";
		
		// do not let enter space-key at beginning of inputline (or multiple spaces) while editing:
		// alternative way would be to restrict Space and then add "space" action where a simmiliar check appears
		inputLine.onInsertText = function(t:TextLine, fromPos:Int, toPos:Int, chars:String) {

			// restrict to max 23 chars: (on TODO in peote-ui!)
			if (t.length > 23) {
				t.deleteChars(fromPos, toPos);
				t.setCursor(t.cursor - (toPos - fromPos)); // <- little glitch if cursor was on first char
				return;
			}

			var s:String = t.text;
			var cleaned = cleanNickName(s);
			if (s != cleaned) {				
				t.setText(cleaned);
				if (cleaned.length < s.length) t.setCursor(t.cursor - (s.length - cleaned.length));
				t.xOffset = 0; // <- to avoid GLITCH in peote-ui if first letter is a space (also updating empty text!)
				t.updateLayout();
			}

			// better add/remove instead of show/hide because the UIarea always is masked and then it will show it on resize also if was hide! (ui-glitch?)
			// if (~/ $/.replace(cleaned, "").length >= 2) connectButton.show();
			if (!connectButton.isVisible && ~/ $/.replace(cleaned, "").length >= 2) add(connectButton);
		}

		inputLine.onDeleteText = function(t:TextLine, fromPos:Int, toPos:Int, chars:String) {
			var s:String = t.text;
			var cleaned = cleanNickName(s);
			if (s != cleaned) {				
				t.setText(cleaned);
				t.xOffset = 0; // <- to avoid GLITCH in peote-ui if first letter is a space (also updating empty text!)
				t.updateLayout();
			}
			// if (~/ $/.replace(cleaned, "").length < 2) connectButton.hide();
			if (connectButton.isVisible && ~/ $/.replace(cleaned, "").length < 2) remove(connectButton);
		}
		
		add(inputLine);
		

		// --- custom keyboard-control via input2action ---
		var actionConfig:ActionConfig = [
			{ action: "enter" , keyboard: [KeyCode.RETURN, KeyCode.NUMPAD_ENTER], single:true },
			// { action: "space" , keyboard: [KeyCode.SPACE], single:false },
		];
		actionConfig.add(InputTextLine.actionConfig, false);
		
		var actionMap:ActionMap = [
			"enter" => {
				action:function(_,_) {
					enter(inputLine.text);
				},
				repeatKeyboardDefault:false
			},			
			/*
			"space" => { action:(_, _) -> {
				if (inputLine.cursor > 0) {
					inputLine.insertChar(" ", inputLine.cursor);
					inputLine.setCursor(inputLine.cursor + 1, false);
					inputLine.updateLayout();
				}
			}, repeatKeyboardDefault:false },
			*/			
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
		}

	}

	function enter(nickName:String) {
		nickName = ~/ $/.replace(nickName, ""); // remove space at line end
		if (nickName.length >= 2) onConnect(nickName);
	}

	public function cleanNickName(s:String):String {
		s = ~/  +/g.replace(s, " "); // multiple spaces
		s = ~/^ /.replace(s, ""); // space at line start
		// s = ~/ $/.replace(s, ""); // space at line end
		// trace('"$s"');
		return s.substr(0, 23);
	}

	public function setInputFocus() if (inputLine.isVisible) inputLine.setInputFocusAt(inputLine.length);

}