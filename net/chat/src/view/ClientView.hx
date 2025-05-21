package view;

import peote.view.PeoteView;

import view.ui.Ui;
import view.ui.Log;
import view.ui.Chat;
import view.ui.NameInput;

import net.Client;

class ClientView {

	var peoteView:PeoteView;
	var ui:Ui;

	var log:Log;
	var chat:Chat;
	var nameInput:NameInput;

	var client:Client;

	var nickName:String;

	public function new(peoteView:PeoteView, x:Int, y:Int, width:Int, height:Int)
	{
		this.peoteView = peoteView;

		// ----- peote-ui -------

		ui = new Ui(x, y, width, height);
		peoteView.addDisplay(ui);
		
		// --------- add logger ----------		
		log = new Log(0, 4, width, getLogHeight());
		ui.add(log);		

		// --------- add login area (enter name) ----------
		nameInput = new NameInput(0, getLogHeight()+8, width, height, connect);
		ui.add(nameInput);		

		// ---------- chat -----------
		chat = new Chat(0, getLogHeight()+8, width, height-getLogHeight(), onChatInput);


		// -----------------------------
		// ----- peote-net client ------
		// -----------------------------

		client = new Client(Config.host, Config.port, Config.channel, log.say);
	}

	public function connect(nickName:String)
	{	
		this.nickName = nickName;
		client.connect(onConnect, onDisconnect);
	}

	public function onConnect()
	{	
		ui.remove(nameInput);
		log.say("connection established \\o/");

		client.setNickName(nickName);

		ui.add(chat);
	}

	public function onDisconnect()
	{	
		ui.remove(chat);
		log.say("connection lost ...");
		ui.add(nameInput);
	}

	public function onChatInput(msg:String)
	{	
		client.send(msg);
	}
	
	
	function getLogHeight():Int return Std.int(ui.height * 0.2);

	public function resize(x:Int, y:Int, w:Int, h:Int) {
		if (ui != null) {
			ui.x = x;
			ui.y = y;
			ui.width = w;
			ui.height = h;
			
			log.width = w;
			log.height = getLogHeight();
			log.updateLayout();

			nameInput.width = w;
			nameInput.height = ui.height-getLogHeight();
			nameInput.y = getLogHeight()+8;
			nameInput.updateLayout();

			chat.width = w;
			chat.height = ui.height-getLogHeight();
			chat.y = getLogHeight()+8;
			chat.updateLayout();
		}
	}

} 