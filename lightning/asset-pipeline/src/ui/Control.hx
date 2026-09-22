package ui;

import peote.ui.config.VAlign;
import peote.ui.config.HAlign;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.UIElement;
import peote.ui.interactive.UITextPage;
import peote.ui.interactive.UITextLine;
import peote.ui.interactive.UISlider;
import peote.ui.interactive.UIArea;
import peote.ui.style.BoxStyle;
import peote.ui.style.RoundBorderStyle;
import peote.ui.config.ResizeType;
import peote.ui.config.TextConfig;
import peote.ui.config.SliderConfig;
import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

import peote.ui.extra.UIAreaList;
import peote.ui.extra.AreaListConfig;

import peote.ui.style.FontStyleTiled;

import ui.ControlValues;

// using macro generated Font and Text-widgets
// -------------------------------------------
// typedef Fnt = peote.text.Font<FontStyleTiled>;
// typedef TextLine = peote.ui.interactive.UITextLine<FontStyleTiled>;
// typedef TextPage = peote.ui.interactive.UITextPage<FontStyleTiled>;

// faster buildtime by using the pre generated:
// --------------------------------------------
typedef Fnt = peote.ui.tiled.FontT;
typedef TextLine = peote.ui.interactive.UITextLineT;
typedef TextPage = peote.ui.interactive.UITextPageT;


class Control extends PeoteUIDisplay
{
	var font:Fnt;

	var isAdded = false;
	var title:String;
	var controlItems:Array<ControlItem>;

	// ---- Styles -----	
	var boxStyle  = new BoxStyle(0x41144ff);		
	var roundBorderStyle = RoundBorderStyle.createById(0, 0x4114455);
	var cursorStyle = BoxStyle.createById(1, Color.RED);
	var selectionStyle = BoxStyle.createById(2, Color.GREY3);
	
	var fontStyleInput = FontStyleTiled.createById(1,{width:9,height:16,color:Color.GREY1});
	var fontStyleFG    = FontStyleTiled.createById(2,{width:9,height:16,color:Color.ORANGE});
	
	// ---- Configs -----	
	var rootConfig:AreaListConfig;
	var rowConfig:AreaListConfig;
	var colConfig:AreaListConfig;

	var textHeaderConfig:TextConfig;
	var textLabelConfig:TextConfig;
	var textButtonConfig:TextConfig;
	var textCheckboxConfig:TextConfig;
	var textInputConfig:TextConfig;
	var rootSliderConfig:SliderConfig;
	var sliderConfig:SliderConfig;
	
	public function new(title:String, x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000, controlItems:Array<ControlItem>) {
		this.title = title;
		this.controlItems = controlItems;
		super(x, y, width, height, color);
	}

	override public function addToPeoteView(peoteView:PeoteView, ?atDisplay:Display, addBefore:Bool=false)
	{
		super.addToPeoteView(peoteView, atDisplay, addBefore);
		
		if (!isAdded)
		{
			isAdded = true;

			setDragArea(0, 0, peoteView.width, peoteView.height);

			new Fnt("assets/font/hack_ascii_small.json").load( init );
		}

	}	
		
	function init(font:Fnt) // don'T forget argument-type here !
	{	
		this.font = font;
					
		// ------ add styles in Order -------
		this.addStyleProgram(roundBorderStyle);
		this.addStyleProgram(boxStyle);
		this.addStyleProgram(selectionStyle);
		this.addFontStyleProgram(fontStyleInput, font);
		this.addFontStyleProgram(fontStyleFG, font);
		this.addStyleProgram(cursorStyle);

		// ---- Configs -----
		rootConfig = {
			backgroundStyle:roundBorderStyle,
			hAlign:HAlign.LEFT,
			maskSpace: {
				top:8,
				right:30,
				left:8,
				bottom:8
			},
			backgroundSpace: {
				// left:5
			}
		}

		rowConfig = {
			backgroundStyle:roundBorderStyle,
			hAlign:HAlign.LEFT,
			maskSpace: {
				top:0,
				right:1,
				left:1,
				bottom:0
			},
			backgroundSpace: {
				// left:5
			}
		};

		colConfig = {
			horizontal:true,
			backgroundStyle:roundBorderStyle,
			vAlign:VAlign.TOP,
			maskSpace: {
				top:0,
				right:1,
				left:1,
				bottom:0
			},
			backgroundSpace: {
				// left:5
			}
		}

		textHeaderConfig = {
			backgroundStyle:roundBorderStyle.copy(Color.RED1-0x84),
			hAlign:HAlign.CENTER,
			textSpace: {top:5, bottom:5}
		};
		textLabelConfig = {
			backgroundStyle:null,
			hAlign:HAlign.CENTER,
			textSpace: {top:5, bottom:5}
		};
		textButtonConfig = {
			backgroundStyle:roundBorderStyle.copy(Color.RED1-0x44),
			hAlign:HAlign.CENTER,
			textSpace: {top:5, bottom:5}
		};
		textCheckboxConfig = {
			backgroundStyle:roundBorderStyle.copy(Color.GREEN1-0x44),
			hAlign:HAlign.CENTER,
			textSpace: {top:5, bottom:5}
		};
		textInputConfig = {
			backgroundStyle:boxStyle.copy(Color.GREY5),
			selectionStyle: selectionStyle,
			cursorStyle: cursorStyle
		};
		rootSliderConfig = {
			backgroundStyle: roundBorderStyle.copy(Color.RED1-0x55, 0x00000000, 0.2),
			draggerStyle: roundBorderStyle.copy(Color.GREY2, Color.GREY2, 0.5),
			// draggerSize:16,
			draggSpace:0,
			backgroundSpace: {top:8, bottom:8, left:8, right:8},
			draggerSpace: {top:8, bottom:8, left:8, right:8}
		};
		sliderConfig = {
			backgroundStyle: roundBorderStyle.copy(Color.RED1-0x55, 0x00000000, 0.2),
			draggerStyle: roundBorderStyle.copy(Color.GREY3, Color.GREY2, 0.5),
			// draggerSize:16,
			draggSpace:0,
			backgroundSpace: {top:8, bottom:8, left:4, right:4},
			draggerSpace: {top:4, bottom:4, left:4, right:4}
		};


		// -------------- header --------------------
		var header = new TextLine(0, 0, width, 0, 2, title, font, fontStyleFG, textHeaderConfig);
		header.onPointerDown = (_, e:PointerEvent)-> startDragging(e);
		header.onPointerUp = (_, e:PointerEvent)-> stopDragging(e);
		add(header);

		// --------------- root UIAreaList -----------------------				
		var areaList = new UIAreaList(0, header.height+2, width, height-(header.height+2), 0, rootConfig);

		add(areaList);
		
		addContentRecursive(areaList, controlItems);

		// ---- Slider to scroll the Area ----				
		var vSlider = new UISlider(areaList.width-30, 0, 30, areaList.height, rootSliderConfig);
		vSlider.onMouseWheel = (_, e:WheelEvent) -> vSlider.setWheelDeltaPixel( e.deltaY, 16 );
		areaList.addFixed(vSlider);		
		// bindings for sliders
		areaList.bindVSlider(vSlider, false);

		// scroll to bottom (have to be after "add" because of text-elements!)
		// areaList.setYOffset(areaList.yOffsetEnd, true, true);					


		/*
		var inputPage = new TextPage(0, 0, 200, 0, 1, "input\ntext by\nUITextPage", font, fontStyleInput, textInputConfig);
		inputPage.onPointerDown = function(t:TextPage, e:PointerEvent) {
			t.setInputFocus(e);
			t.startSelection(e);
		}
		inputPage.onPointerUp = function(t:TextPage, e:PointerEvent) {
			t.stopSelection(e);
		}
		
		areaList.add(inputPage);
		inputPage.onResizeHeight = areaList.updateChildOnResizeHeight;		
		*/
	}	
	
	function addContentRecursive(area:UIAreaList, controlItems:Array<ControlItem>):UIArea
	{
		for (item in controlItems) area.add(switch(item) {
			case Row(size, items):
				addContentRecursive( new UIAreaList( 0, 0, size, 0, 0, rowConfig), items);
		
			case Col(size, items):
				addContentRecursive( new UIAreaList( 0, 0, 0, size, 0, colConfig), items);
						
			case Seperator:
				trace("Seperator");
				new UIElement(0, 0, 2, 2, 0, roundBorderStyle);

			case Label(name, size):
				trace("Label " + name, size);
				var label = new TextLine(0, 0, size, 0, 2, name, font, fontStyleFG, textLabelConfig);
				label;
						
			case Button(name, size, onClick):
				trace("Button " + name, size);
				var button = new TextLine(0, 0, size, 0, 2, name, font, fontStyleFG, textButtonConfig);
				if (onClick!=null) button.onPointerClick = function(b, e) onClick();
				button;
				
			case Checkbox(nameFalse, nameTrue, size, value, onChange):
				trace("Checkbox " + nameFalse, size);
				var name = nameFalse;
				if (value!=null) {
					if (value.value) name = nameTrue;
				}
				var checkbox = new TextLine(0, 0, size, 0, 2, name, font, fontStyleFG, textCheckboxConfig);

				if (value==null) value = new BoolValue(false);
				else value.onChange = function(v:Bool) {checkbox.setText( (v) ? nameTrue : nameFalse );checkbox.update();}

				checkbox.onPointerClick = function(b, e) {
					value.value = !value.value;
					checkbox.setText( (value.value) ? nameTrue : nameFalse );
					checkbox.update();
					// if (nameOff!=null) nameOff
					if (onChange!=null) onChange(value.value);
				}
				checkbox;
						
			// case HSlider(name, size, value, valueStart, valueEnd, onChange) | VSlider(name, size, value, valueStart, valueEnd, onChange):
			case Slider(name, size, value, valueStart, valueEnd, onChange):
				trace("Slider " + name, size, item.getName());
				// if (item.getName() == "HSlider")
				var slider:UISlider = new UISlider(0, 0, size, 30, 0, sliderConfig);
				slider.setRange((valueStart!=null) ? valueStart : 0.0, (valueEnd!=null) ? valueEnd : 1.0, false, false);
				slider.onMouseWheel = (_, e:WheelEvent) -> slider.setWheelDeltaPixel( e.deltaY, 16 );
				slider.onChange = function(_, v:Float, _) {
					if (value!=null) value.value = v;
					if (onChange!=null) onChange(v);
				}				
				if (value!=null) {
					slider.value = value;
					value.onChange = function(v:Float) slider.setValue(v, false, false);
				}
				slider;
		});
		
		return area;
	}

}
