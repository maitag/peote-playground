package ui;

import peote.view.Color;
import peote.ui.style.interfaces.FontStyle;
// ------------------------------------------
// --- using a custom FontStyle here --------
// ------------------------------------------

@globalLineSpace // all pageLines using the same page.lineSpace (gap to next line into page)
@:structInit
class FontStyleEdit implements FontStyle
{
	public var color:Color = Color.BLACK;
	//public var color:Color = Color.GREEN.setAlpha(0.5);
	public var width:Float = 10; // (<- is it still fixed to get from font-defaults if this is MISSING ?)
	public var height:Float = 18;
}
