package ui;
import ui.ControlValues;
import peote.ui.config.HAlign;
import peote.view.Color;

enum Align {
	Left;
	Right;
	Center;
}

enum ControlItem {
	Separator;
	Row( ?size:Int, items:Array<ControlItem>);
	Col( ?size:Int, items:Array<ControlItem>);
	Label   (name:String, ?size:Int);
	Button  (name:String, ?size:Int, ?onClick:Void->Void);
	
	InputString (?size:Int, ?align:Align, ?value:StringValue, ?onChange:String->Void);
	OutputString(?size:Int, ?align:Align, ?value:StringValue);
	InputInt    (?size:Int, ?align:Align, ?value:IntValue, ?onChange:Int->Void);
	OutputInt   (?size:Int, ?align:Align, ?value:IntValue);
	InputFloat  (?size:Int, ?align:Align, ?value:FloatValue, ?onChange:Float->Void);
	OutputFloat (?size:Int, ?align:Align, ?value:FloatValue);

	Checkbox(nameFalse:String, ?nameTrue:String, ?size:Int, ?value:BoolValue, ?onChange:Bool->Void);
	Slider  (name:String, ?size:Int, ?value:FloatValue, ?valueStart:Float, ?valueEnd:Float, ?onChange:Float->Void);
	// HSlider  (name:String, ?size:Int, ?value:FloatValue, ?valueStart:Float, ?valueEnd:Float, onChange:Float->Void);
	// VSlider  (name:String, ?size:Int, ?value:FloatValue, ?valueStart:Float, ?valueEnd:Float, onChange:Float->Void);
}
