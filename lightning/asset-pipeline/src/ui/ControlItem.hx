package ui;
import ui.ControlValues;

enum ControlItem {
	Seperator;
	Row( size:Int, items:Array<ControlItem>);
	Col( size:Int, items:Array<ControlItem>);
	Label   (name:String, ?size:Int);
	Button  (name:String, ?size:Int, onClick:Void->Void);
	// IntIn ();
	// IntOut ();
	// FloatIn ();
	// FloatOut ();
	Checkbox(nameFalse:String, ?nameTrue:String, ?size:Int, ?value:BoolValue, onChange:Bool->Void);
	Slider  (name:String, ?size:Int, ?value:FloatValue, ?valueStart:Float, ?valueEnd:Float, onChange:Float->Void);
	// HSlider  (name:String, ?size:Int, ?value:FloatValue, ?valueStart:Float, ?valueEnd:Float, onChange:Float->Void);
	// VSlider  (name:String, ?size:Int, ?value:FloatValue, ?valueStart:Float, ?valueEnd:Float, onChange:Float->Void);
}
