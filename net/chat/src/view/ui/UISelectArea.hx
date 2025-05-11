package view.ui;

import peote.view.Color;

import peote.text.Font;

import peote.ui.interactive.*;
import peote.ui.style.*;
import peote.ui.config.*;
import peote.ui.event.*;

import peote.ui.interactive.interfaces.ParentElement;

class UISelectArea extends UIArea implements ParentElement
{
	public function new(xPosition:Int, yPosition:Int, width:Int, itemHeight:Int, itemGap:Int, zIndex:Int = 0,
		items:Array<String>, font:Font<FontStyleTiled>, fontStyle:FontStyleTiled,
		textConfig:TextConfig,
		?config:AreaConfig
	) 
	{
		super(xPosition, yPosition, width, (itemHeight + itemGap)*items.length - itemGap, zIndex, config);
		
		
		var yPos:Int = 0;
		
		for (i in 0...items.length)
		{
			var textline = new UITextLine<FontStyleTiled>(0, yPos, width, itemHeight, 1, items[i], font, fontStyle, textConfig);
			yPos += itemHeight + itemGap;
			
			textline.onPointerDown = _onSelect.bind(i, _, _);

			// TODO
			textline.onPointerOver = function(t:UITextLine<FontStyleTiled>, e:PointerEvent) { t.backgroundStyle.color = Color.GREY7; t.updateStyle(); };
			textline.onPointerOut  = function(t:UITextLine<FontStyleTiled>, e:PointerEvent) { t.backgroundStyle.color = Color.GREY5; t.updateStyle(); };
			
			add(textline);
		}
		
		this.height = innerHeight;
	}
	
	inline function _onSelect(index:Int, t:UITextLine<FontStyleTiled>, e:PointerEvent) {
		if (onSelect != null) onSelect(this, index, t.text);
	}
	
	// events
	public var onSelect:UISelectArea -> Int -> String ->Void = null;
	
}
