package ui;

enum ControlItem {
	Seperator;
	Row( size:Int, items:Array<ControlItem>);
	Col( size:Int, items:Array<ControlItem>);
	Label   (name:String, ?size:Int);
	Button  (name:String, ?size:Int, onClick:Void->Void);
	Checkbox(name:String, ?size:Int, onChange:Bool->Void);
	Slider  (name:String, ?size:Int, onChange:Float->Void);
}
