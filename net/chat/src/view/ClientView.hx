package view;

import peote.view.PeoteView;

import view.ui.Ui;
import view.ui.LogArea;

import net.Client;

class ClientView {

	var peoteView:PeoteView;
	var ui:Ui;

	var logArea:LogArea;

	public function new(peoteView:PeoteView, x:Int, y:Int, width:Int, height:Int)
	{
		this.peoteView = peoteView;

		ui = new Ui(x, y, width, height);
		peoteView.addDisplay(ui);
		
		
		// --------- logger ----------
		
		logArea = new LogArea(0, getLogYPos(), width, getLogHeight());
		// logArea = new LogArea(0, getLogYPos(), width, getLogHeight(), "=== client logger ===");
		ui.add(logArea);
		
		
		
		// --------------------------------
		// ---------- network -------------
		// --------------------------------

		var host:String = haxe.macro.Compiler.getDefine("host");
		if (host == null) host = "localhost";
		var port:Null<Int> = Std.parseInt(haxe.macro.Compiler.getDefine("port"));
		if (port==null) port = 7680;
		var channel:String = haxe.macro.Compiler.getDefine("channel");
		if (channel == null) channel = "peotechat";
		
		logArea.log('try to connect to $host:$port\nenter channel "$channel" ...');
		new Client(host, port, channel, logArea.log);

	}

	function getLogYPos():Int return ui.height-Std.int(ui.height * 0.2);
	function getLogHeight():Int return Std.int(ui.height * 0.2);

	public function resize(x:Int, y:Int, w:Int, h:Int) {
		if (ui != null) {
			ui.x = x;
			ui.y = y;
			ui.width = w;
			ui.height = h;
			
			logArea.y = getLogYPos();
			logArea.width = w;
			logArea.height = getLogHeight();
			logArea.updateLayout();
		}
	}

} 