package view;

import net.Server;

import peote.view.PeoteView;
import peote.ui.PeoteUIDisplay;

class ServerView {

	var peoteView:PeoteView;
	
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;

	public function new(peoteView:PeoteView, x:Int, y:Int, width:Int, height:Int, offline:Bool = false)
	{
		this.peoteView = peoteView;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;

		// -------------------------------------------------------
		// --- PeoteUIDisplay with styles in Layer-Depth-Order ---
		// -------------------------------------------------------
		/*
		peoteUiDisplay = new PeoteUIDisplay(0, 0, peoteView.width, peoteView.height,
			[ Ui.layer0_style, Ui.layer1_style, Ui.layer2_style, Ui.layer3_style ]
		);
		peoteView.addDisplay(peoteUiDisplay);
		
		// --------------------------------
		// --------- text output ----------
		// --------------------------------
		
		var areaTextInOut = new AreaTextOutput(0, 100, 500, 450, 0, Ui.styleServerLogArea);
		peoteUiDisplay.add(areaTextInOut);
		
		// ---------------------------------------------------------
		PeoteUIDisplay.registerEvents(peoteView.window);

		*/

		var host:String = "localhost";
		var port:Int = 7680;
		var channel:String = "haxechat";
						
		new Server(host, port, channel, offline);

	}


} 