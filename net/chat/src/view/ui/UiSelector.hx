package view.ui;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.*;
import peote.ui.style.*;
import peote.ui.config.*;
import peote.ui.event.*;

class UiSelector
{
	var peoteView:PeoteView;
	var peoteUiDisplay:PeoteUIDisplay;
	var onInit:Void->Void;

	public function new(peoteView:PeoteView, onInit:Void->Void)
	{
		this.peoteView = peoteView;
		this.onInit = onInit;
		new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:Font<FontStyleTiled>) // don'T forget argument-type here !
	{
		// ---- background layer styles -----

		var boxStyle  = BoxStyle.createById(0);
		var fontStyle = FontStyleTiled.createById(0);
		
		var textConfig:TextConfig = {
			backgroundStyle:boxStyle.copy(Color.GREY5),
			textSpace: {left:10},
		}
		
		// ---- foreground layer styles -----
		
		var boxStyleFront = BoxStyle.createById(1);
		var fontStyleFront = FontStyleTiled.createById(1);

		var textConfigFront:TextConfig = {
			backgroundStyle:boxStyleFront.copy(Color.GREY5),
			textSpace: {left:10},
		}
		
		// -------------------------------------------------------
		// --- PeoteUIDisplay with styles in Layer-Depth-Order ---
		// -------------------------------------------------------
		
		peoteUiDisplay = new PeoteUIDisplay(0, 0, peoteView.width, peoteView.height,
			[ boxStyle, fontStyle, boxStyleFront, fontStyleFront ]
		);
		peoteView.addDisplay(peoteUiDisplay);
		
		// --------------------------------
		// ---- creating Select-Area ------
		// --------------------------------
		
		var itemHeight:Int = 20;
		var itemGap:Int = 1;

		var selectArea = new UISelectArea(100, 100, 160, itemHeight, itemGap, 1,
			["item 0", "item 1", "item 2", "item 3", "item 4"],
			font, fontStyleFront, textConfigFront,
			boxStyleFront 
		);		
		peoteUiDisplay.add(selectArea);
		selectArea.hide(); // hide it instantly
		
		
		// ----------------------------------
		// ---- creating Selector-Button ----
		// ----------------------------------
		
		var selector = new UITextLine<FontStyleTiled>(100, 100, 160, itemHeight, 0, "item 0", font, fontStyle, textConfig);
		selector.onPointerDown = function(t:UITextLine<FontStyleTiled>, e:PointerEvent)
		{
			selectArea.show();
		};				
		peoteUiDisplay.add(selector);
		
		
		// -- change selector text on select --
		
		selectArea.onSelect = (area:UISelectArea, item:Int, text:String) -> {
			trace('item $item selected -> $text');
			selector.setText(text);
			// selector.vAlign = VAlign.CENTER;
			// selector.hAlign = HAlign.LEFT;
			selector.setXOffset(0);
			selector.updateLayout();

			area.hide();
		}
		
		
		// ---------------------------------------------------------
		PeoteUIDisplay.registerEvents(peoteView.window);

		onInit();
	}	

	
}

