package view;

import peote.view.PeoteView;

import view.ui.Ui;
import view.ui.Log;

import net.Client;

class ClientView {

	var peoteView:PeoteView;
	var ui:Ui;

	var log:Log;

	public function new(peoteView:PeoteView, x:Int, y:Int, width:Int, height:Int)
	{
		this.peoteView = peoteView;

		ui = new Ui(x, y, width, height);
		peoteView.addDisplay(ui);
		
		
		// --------- logger ----------
		
		log = new Log(0, getLogYPos(), width, getLogHeight());
		// log = new Log(0, getLogYPos(), width, getLogHeight(), "=== client logger ===");
		ui.add(log);
		
		// log.say("OK");
		
		// --------------------------------
		// ---------- network -------------
		// --------------------------------

		new Client(Config.host, Config.port, Config.channel, log.say);

	}

	function getLogYPos():Int return ui.height-Std.int(ui.height * 0.2);
	function getLogHeight():Int return Std.int(ui.height * 0.2);

	public function resize(x:Int, y:Int, w:Int, h:Int) {
		if (ui != null) {
			ui.x = x;
			ui.y = y;
			ui.width = w;
			ui.height = h;
			
			log.y = getLogYPos();
			log.width = w;
			log.height = getLogHeight();
			log.updateLayout();
		}
	}

} 