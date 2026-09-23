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
import peote.ui.style.interfaces.Style;
import peote.ui.config.ResizeType;
import peote.ui.config.ElementConfig;
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
	var cursorStyle = BoxStyle.createById(1, Color.RED1);
	var selectionStyle = BoxStyle.createById(2, Color.GREY2);
	
	var fontStyle = FontStyleTiled.createById(1,{width:9,height:16,color:0xd68230ff});
	var fontStyleInput:FontStyleTiled;
	var fontStyleOutput:FontStyleTiled;
	var fontStyleFG = FontStyleTiled.createById(2,{width:9,height:16,color:0xd68230ff});

	// specific styles
	var checkboxBgStyleTrue:Style;
	var checkboxBgStyleFalse:Style;
	
	// ---- Configs -----	
	var rootConfig:AreaListConfig;
	var rowConfig:AreaListConfig;
	var colConfig:AreaListConfig;
	
	var separatorConfig:ElementConfig;

	var textHeaderConfig:TextConfig;
	var textLabelConfig:TextConfig;
	var textButtonConfig:TextConfig;
	
	var textInputConfig:TextConfig;
	var textOutputConfig:TextConfig;
	
	var textCheckboxConfig:TextConfig;
	
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
		this.addFontStyleProgram(fontStyle, font);
		this.addFontStyleProgram(fontStyleFG, font);
		this.addStyleProgram(cursorStyle);

		// ---- Configs -----
		rootConfig = {
			backgroundStyle:roundBorderStyle,
			hAlign:HAlign.LEFT,
			gap:6,
			maskSpace: {
				top:8,
				right:30,
				left:8,
				bottom:8
			},
			backgroundSpace: {
				// bottom:8
			}
		}

		// TODO: better define all configs from here inside the SWITCH-statements (lesser globally vars!!!)
		rowConfig = {
			backgroundStyle:roundBorderStyle,
			hAlign:HAlign.LEFT,
			gap:2,
			maskSpace: {
				top:2,
				right:0,
				left:3,
				bottom:2
			},
			backgroundSpace: {
				// left:5
			}
		};

		colConfig = {
			horizontal:true,
			backgroundStyle:null,
			vAlign:VAlign.TOP,
			gap:4,
			maskSpace: {
				top:0,
				right:0,
				left:0,
				bottom:0
			},
			backgroundSpace: {
				// left:5
			}
		}

		textHeaderConfig = {
			backgroundStyle:roundBorderStyle.copy(Color.RED1-0x44),
			hAlign:HAlign.CENTER,
			textSpace: {top:5, bottom:5}
		};

		separatorConfig = {
			backgroundStyle:boxStyle.copy(0x55667788),
		}

		textLabelConfig = {
			backgroundStyle:null,
			hAlign:HAlign.CENTER,
			textSpace: {top:2, bottom:2}
		};

		textButtonConfig = {
			backgroundStyle:roundBorderStyle.copy(Color.RED1-0x44),
			hAlign:HAlign.CENTER,
			textSpace: {top:2, bottom:2}
		};

		
		fontStyleInput = fontStyle.copy(0x070403ff, 9, 16);
		
		textInputConfig = {
			backgroundStyle:boxStyle.copy(0x736860cc),
			selectionStyle: selectionStyle,
			cursorStyle: cursorStyle,
			textSpace: {top:2, bottom:2, left:3, right:3}
		};

		fontStyleOutput = fontStyle.copy(0x070403ff, 9, 16, 0.0, -1);

		textOutputConfig = {
			backgroundStyle:roundBorderStyle.copy(0x736860cc, 0x736860cc, 0),
			hAlign:HAlign.RIGHT,
			textSpace: {top:2, bottom:2, left:3, right:3}
		};


		checkboxBgStyleFalse = roundBorderStyle.copy(Color.RED1-0x44);
		checkboxBgStyleTrue = roundBorderStyle.copy(0x0a3406cc);
		textCheckboxConfig = {
			backgroundStyle:checkboxBgStyleFalse,
			hAlign:HAlign.CENTER,
			textSpace: {top:2, bottom:2}
		};


		rootSliderConfig = {
			backgroundStyle: roundBorderStyle.copy(Color.RED1-0x55, 0x00000000, 0.2),
			draggerStyle: roundBorderStyle.copy(0x736860cc, 0x736860cc, 0),
			// draggerSize:16,
			draggSpace:0,
			backgroundSpace: {top:6, bottom:6, left:8, right:8},
			draggerSpace: {top:8, bottom:8, left:10, right:10}
		};
		sliderConfig = {
			backgroundStyle: roundBorderStyle.copy(Color.RED1-0x55, 0x00000000, 0.2),
			draggerStyle: roundBorderStyle.copy(0x736860cc, 0x736860cc, 0),
			// draggerSize:16,
			draggSpace:0,
			backgroundSpace: {top:3, bottom:3, left:0, right:0},
			// draggerSpace: {top:0, bottom:0, left:0, right:0}
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
		areaList.bindVSlider(vSlider, false);
		// scroll to bottom (have to be after "add" because of text-elements!)
		// areaList.setYOffset(areaList.yOffsetEnd, true, true);
	}	
	
	function addContentRecursive(area:UIAreaList, controlItems:Array<ControlItem>):UIArea
	{
		for (item in controlItems) area.add(switch(item) {
			case Row(size, items):
				if (size == null) size = 200;
				addContentRecursive( new UIAreaList( 0, 0, size, size, 0, rowConfig), items);
		
			case Col(size, items):
				if (size == null) size = 20;
				addContentRecursive( new UIAreaList( 0, 0, size, size, 0, colConfig), items);
						
			case Separator:
				var area = new UIArea(0, 0, 0, 20);
				var separator = new UIElement(0, 9, 300, 2, 0, separatorConfig);
				area.onResizeWidth = (_, w:Int,_) -> separator.width = w;
				area.add(separator);
				// separator;
				area;

			case Label(name, size):
				var label = new TextLine(0, 0, size, 0, 2, name, font, fontStyle, textLabelConfig);
				label;
						
			case Button(name, size, onClick):
				var button = new TextLine(0, 0, size, 0, 2, name, font, fontStyle, textButtonConfig);
				if (onClick!=null) button.onPointerClick = function(b, e) onClick();
				button;
			
			
			case InputString(size, align, value, onChange):
				if (size == null) size = 200;
				var hAlign:HAlign = switch(align) {
					case Left:HAlign.LEFT;
					case Right:HAlign.RIGHT;
					case Center:HAlign.CENTER;
					default: HAlign.LEFT;
				}
				var input = new TextLine(0, 0, size, 0, 2, (value!=null) ? value : "", font, fontStyleInput, textInputConfig);
				input.hAlign=hAlign;
				input.restrictedChars = "a-zA-Z0-9+-*~/\\^.,;:§$%&=?_#\"'`[](){}%&<>| ";

				input.onPointerDown = function(t:TextLine, e:PointerEvent) {
					t.setInputFocus(e);
					t.startSelection(e);
				}
				input.onPointerUp = function(t:TextLine, e:PointerEvent) {
					t.stopSelection(e);
				}
				input.onInsertText = input.onDeleteText = function(t:TextLine, _, _, _) {
					if (onChange!=null) onChange(input.text);
					if (value!=null) @:bypassAccessor value.value = input.text;
				}
		
				if (value!=null) {
					value.onChange = function(v:String) {input.setText(Std.string(v)); input.xOffset=0; input.hAlign=hAlign; input.update();}
				}
				input;

			case OutputString(size, align, value):
				if (size == null) size = 200;
				var hAlign:HAlign = switch(align) {
					case Left:HAlign.LEFT;
					case Right:HAlign.RIGHT;
					case Center:HAlign.CENTER;
					default: HAlign.LEFT;
				}
				var output = new TextLine(0, 0, size, 0, 2, (value!=null) ? value : "", font, fontStyleOutput, textOutputConfig);
				output.hAlign=hAlign;

				if (value!=null) {
					value.onChange = function(v:String) {output.setText(Std.string(v)); output.xOffset=0; output.hAlign=hAlign; output.update();}
				}
				output;

			case InputInt(size, align, value, onChange):
				if (size == null) size = 46;
				var hAlign:HAlign = switch(align) {
					case Left:HAlign.LEFT;
					case Right:HAlign.RIGHT;
					case Center:HAlign.CENTER;
					default: HAlign.LEFT;
				}
				var input = new TextLine(0, 0, size, 0, 2, (value!=null) ? value : "", font, fontStyleInput, textInputConfig);
				input.hAlign=hAlign;
				input.restrictedChars = "0-9-";

				input.onPointerDown = function(t:TextLine, e:PointerEvent) {
					t.setInputFocus(e);
					t.startSelection(e);
				}
				input.onPointerUp = function(t:TextLine, e:PointerEvent) {
					t.stopSelection(e);
				}
				input.onInsertText = input.onDeleteText = function(t:TextLine, _, _, _) {
					if (onChange!=null) onChange(Std.parseInt(input.text));
					if (value!=null) @:bypassAccessor value.value = Std.parseInt(input.text);
				}
		
				if (value!=null) {
					value.onChange = function(v:Int) {input.setText(Std.string(v)); input.xOffset=0; input.hAlign=hAlign; input.update();}
				}
				input;

			case OutputInt(size, align, value):
				if (size == null) size = 46;
				var hAlign:HAlign = switch(align) {
					case Left:HAlign.LEFT;
					case Right:HAlign.RIGHT;
					case Center:HAlign.CENTER;
					default: HAlign.LEFT;
				}
				var output = new TextLine(0, 0, size, 0, 2, (value!=null) ? value : "", font, fontStyleOutput, textOutputConfig);
				output.hAlign=hAlign;

				if (value!=null) {
					value.onChange = function(v:Int) {output.setText(Std.string(v)); output.xOffset=0; output.hAlign=hAlign; output.update();}
				}
				output;

			case InputFloat(size, align, value, onChange):
				if (size == null) size = 58;
				var hAlign:HAlign = switch(align) {
					case Left:HAlign.LEFT;
					case Right:HAlign.RIGHT;
					case Center:HAlign.CENTER;
					default: HAlign.LEFT;
				}
				var input = new TextLine(0, 0, size, 0, 2, (value!=null) ? value : "", font, fontStyleInput, textInputConfig);
				input.hAlign=hAlign;
				input.restrictedChars = ".0-9-";

				input.onPointerDown = function(t:TextLine, e:PointerEvent) {
					t.setInputFocus(e);
					t.startSelection(e);
				}
				input.onPointerUp = function(t:TextLine, e:PointerEvent) {
					t.stopSelection(e);
				}
				input.onInsertText = input.onDeleteText = function(t:TextLine, _, _, _) {
					if (onChange!=null) onChange(Std.parseFloat(input.text));
					if (value!=null) @:bypassAccessor value.value = Std.parseFloat(input.text);
				}
		
				if (value!=null) {
					value.onChange = function(v:Float) {input.setText(Std.string(v)); input.xOffset=0; input.hAlign=hAlign; input.update();}
				}
				input;

			case OutputFloat(size, align, value):
				if (size == null) size = 58;
				var hAlign:HAlign = switch(align) {
					case Left:HAlign.LEFT;
					case Right:HAlign.RIGHT;
					case Center:HAlign.CENTER;
					default: HAlign.LEFT;
				}
				var output = new TextLine(0, 0, size, 0, 2, (value!=null) ? value : "", font, fontStyleOutput, textOutputConfig);
				output.hAlign=hAlign;

				if (value!=null) {
					value.onChange = function(v:Float) {output.setText(Std.string(v)); output.xOffset=0; output.hAlign=hAlign; output.update();}
				}
				output;

			
			case Checkbox(nameFalse, nameTrue, size, value, onChange):
				var name = nameFalse;
				if (value!=null) {
					if (value.value) name = nameTrue;
					textCheckboxConfig.backgroundStyle = (value.value) ? checkboxBgStyleTrue : checkboxBgStyleFalse;
				} 
				// else textCheckboxConfig.backgroundStyle = checkboxBgStyleFalse;
				var checkbox = new TextLine(0, 0, size, 0, 2, name, font, fontStyle, textCheckboxConfig);
				
				if (value==null) value = new BoolValue(false);
				else value.onChange = function(v:Bool) {checkbox.setText( (v) ? nameTrue : nameFalse );checkbox.update();}

				checkbox.onPointerClick = function(b, e) {
					value.value = !value.value;
					checkbox.setText( (value.value) ? nameTrue : nameFalse );
					checkbox.backgroundStyle = (value.value) ? checkboxBgStyleTrue : checkboxBgStyleFalse;
					checkbox.update();
					if (onChange!=null) onChange(value.value);
				}
				checkbox;
						
			// case HSlider(name, size, value, valueStart, valueEnd, onChange) | VSlider(name, size, value, valueStart, valueEnd, onChange):
			case Slider(name, size, value, valueStart, valueEnd, onChange):
				// if (item.getName() == "HSlider")
				var slider:UISlider = new UISlider(0, 0, size, 20, 0, sliderConfig);
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
