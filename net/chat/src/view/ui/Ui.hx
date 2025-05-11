package view.ui;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.style.interfaces.Style;
import peote.ui.style.*;
import peote.ui.config.*;

@:publicFields
class Ui
{
	static var font:Font<FontStyleTiled>;

	// ---- PeoteUiDisplay style-layers ---
	
	static var layer0_style = BoxStyle.createById(0);
	static var layer1_style = FontStyleTiled.createById(0);
	// static var layer2_style:RoundBorderStyle;
	// static var layer3_style:Style;


	// --- styles for specific ui elements ---

	// static var styleServerLogArea:Style;

	static function init(onInit:Void->Void)
	{
/*		// ---- background layer styles -----

		var boxStyleBG  = BoxStyle.createById(0);
		var fontStyleBG = FontStyleTiled.createById(0);
		
		
		// ---- foreground layer styles -----
		
		var boxStyleFG = BoxStyle.createById(1);
		var fontStyleFG = FontStyleTiled.createById(1);
*/
		new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( 
			(f:Font<FontStyleTiled>) -> {
				font = f;
				onInit();
			}
		);
	}
	
}

