package view.ui;

import peote.ui.style.interfaces.Style;
import peote.ui.interactive.UIArea;
import peote.ui.config.AreaConfig;
import peote.ui.config.ResizeType;

class AreaTextOutput extends UIArea {

	var buffer:Array<String> = [
		"short line",
		"0123456789 0123456789 0123456789 0123456789 0123456789" // 54 chars
	];

	var wordWrapAt:Int = 10;
	var wrappedLines = new Array<Int>(); // all lines that are wrapped
  
	public function new(x:Int, y:Int, w:Int, h:Int, z:Int, bgStyle:Style) {


		var areaConfig:AreaConfig = {
			backgroundStyle: bgStyle,
			backgroundSpace: {left:0, top:0, right:0, bottom:0},
			resizeType: ResizeType.RIGHT,
			resizerSize: 5,
			resizerEdgeSize: 7,
			minWidth: 300,
			maxWidth: 2000,
			minHeight: 200,
			maxHeight: 2000,
		};

		super(x, y, w, h, z, areaConfig);

		onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			trace(width);
		}





	}



}