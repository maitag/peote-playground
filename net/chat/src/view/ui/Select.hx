package view.ui;

// TODO: make all child of uitextline!!!

class Select
{
    public function new(x:Int, y:Int, width:Int, itemHeight:Int, itemGap:Int, border:Int, zIndex:Int = 0,
		items:Array<String>, defaultItem:Int = 0
    ) 
    {
        
		// --------------------------------
		// ---- creating Select-Area ------
		// --------------------------------

		var selectArea = new UISelectArea(x, y, width, itemHeight, itemGap, border, zIndex+1, items, defaultItem, Ui.selectAreaConfig);		
		Ui.display.add(selectArea);
		selectArea.hide(); // hide it instantly
		
		
		// ----------------------------------
		// ---- creating Selector-Button ----
		// ----------------------------------
		
		var selector = new TextLine(x, y, width, itemHeight, zIndex, items[defaultItem], Ui.font, Ui.fontStyle_0, Ui.textConfigSelect_0);
		selector.onPointerDown = function(t:TextLine, e:PointerEvent)
		{
			selectArea.show();
		};				
		Ui.display.add(selector);
		
		
		// -- change selector text on select --
		
		selectArea.onSelect = (area:UISelectArea, itemNumber:Int, text:String) -> {
			selector.setText(text);
			// selector.vAlign = VAlign.CENTER;
			// selector.hAlign = HAlign.LEFT;
			selector.setXOffset(0);
			selector.updateLayout();

			area.hide();

			if (onSelect != null)  onSelect(this, itemNumber, text);
		}

		
		// --- stop selection if mouse out ----
		selectArea.pointerOverOnHide = false;
		selectArea.onPointerOut = (area:UIElement,e:PointerEvent) -> {
			// trace("OUT", selectArea.isOUT);
			/*if (selectArea.isOUT) haxe.Timer.delay(()->{
				if (selectArea.isOUT) selectArea.hide();
			},200);*/
			if (selectArea.isOUT) selectArea.hide();
		}
		/*
		selectArea.onPointerOver = (area:UIElement,e:PointerEvent) -> {
			trace("OVER\n");
		}
		*/

    }

	// events
	public var onSelect:UISelect -> Int -> String ->Void = null;

}


class UISelectArea extends UIArea implements peote.ui.interactive.interfaces.ParentElement
{
	public var isOUT(default, null) = false;
	public var selected:Int = 0;

	var textLines = new Array<TextLine>();

	public function new(x:Int, y:Int, width:Int, itemHeight:Int, itemGap:Int, border:Int, zIndex:Int = 0,
		items:Array<String>, defaultItem:Int = 0,
        ?config:AreaConfig
	) 
	{
		super(x-border, y-border, width+border+border, border+border + (itemHeight + itemGap)*items.length - itemGap, zIndex, config);
		
		selected = defaultItem;
		
		var yPos:Int = border;
		
		var indices:Array<Int> = [selected];
		for (i in 0...items.length) if (i != selected) indices.push(i);
		
		for (i in indices)
		// for (i in 0...items.length)
		{	
			var textline = new TextLine(0, yPos, width+border+border, itemHeight+((i < indices.length-1) ? itemGap : 0), zIndex, items[i], Ui.font, Ui.fontStyle_1, Ui.textConfigSelect_1);
			textline.backgroundSpace = {
				bottom: (i < indices.length-1) ? itemGap : 0,
				left:border,
				right:border
			};
			textline.leftSpace += border;
			textline.topSpace -= (i < indices.length-1) ? itemGap : 0;

			yPos += itemHeight+itemGap;
			
			textline.onPointerDown = _onSelect.bind(i, _, _);

			textline.onPointerOver = function(t:TextLine, e:PointerEvent) {
				isOUT = false;
				t.backgroundStyle.color = Color.GREY7; t.updateStyle();
			};

			textline.pointerOverOnHide = false;
			textline.onPointerOut  = function(t:TextLine, e:PointerEvent) {
				t.backgroundStyle.color = Color.GREY5; t.updateStyle();
				if (e.x < left || e.y < top+border || e.x >= right || e.y >= bottom - border) isOUT = true;
			};

			textLines[i] = textline;
			add(textline);
		}
		
		//this.height = innerHeight;
	}

	/*
	override public function show() {
		super.show();
		trace("SHOW");
	}
	*/
	
	inline function _onSelect(index:Int, t:TextLine, e:PointerEvent) {
		if (onSelect != null) {

			var yPos:Int = textLines[selected].y;

			selected = index;

			// re-arrange order
			var indices:Array<Int> = [selected];
			for (i in 0...textLines.length) if (i != selected) indices.push(i);
			
			
			for (i in indices) {
				textLines[i].y = yPos;
				textLines[i].updateVisibleLayout();
				yPos += textLines[i].height;
			}

			onSelect(this, index, t.text);
		}
	}
	
	// events
	public var onSelect:UISelectArea -> Int -> String ->Void = null;
	
}
