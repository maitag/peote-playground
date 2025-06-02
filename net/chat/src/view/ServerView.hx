package view;

import peote.view.PeoteView;

import view.ui.Ui;
import view.ui.Log;

import net.Server;

class ServerView {

	var peoteView:PeoteView;
	var ui:Ui;
	
	var log:Log;

	public function new(peoteView:PeoteView, x:Int, y:Int, width:Int, height:Int, offline:Bool = false)
	{
		this.peoteView = peoteView;
		
		// ---------------------------
		// -------- peote-ui ---------
		// ---------------------------

		ui = new Ui(x, y, width, height);
		peoteView.addDisplay(ui);
		
		// --------- logger ----------
		
		log = new Log(0, 0, width, height);
		ui.add(log);		
		
		// ---------------------------
		// ---- peote-net server -----
		// ---------------------------
		
		new Server(Config.host, Config.port, Config.channel, log.say, offline);
	}


	// ---------------------------------------------------------
	// ---------------- resizing window ------------------------
	// ---------------------------------------------------------

	public function resize(x:Int, y:Int, w:Int, h:Int) {
		if (ui != null) {
			ui.x = x;
			ui.y = y;
			ui.width = w;
			ui.height = h;

			log.width = w;
			log.height = h;
			log.updateLayout();
		}
	}
} 