package view;

import peote.view.PeoteView;

import view.ui.Ui;
import view.ui.Log;
import view.ui.Chat;
import view.ui.NameInput;

import net.Client;
import peote.net.Reason;

class ClientView {

	var peoteView:PeoteView;
	var ui:Ui;

	#if clientLogArea
	var log:Log;
	#end
	var chat:Chat;
	var nameInput:NameInput;

	var client:Client;

	var nickName:String;

	var onMissingServer:Void->Void;

	public function new(peoteView:PeoteView, x:Int, y:Int, width:Int, height:Int, onMissingServer:Void->Void = null)
	{
		this.peoteView = peoteView;
		this.onMissingServer = onMissingServer;

		// ---------------------------
		// -------- peote-ui ---------
		// ---------------------------

		ui = new Ui(x, y, width, height);
		peoteView.addDisplay(ui);
		
		#if clientLogArea
		// --------- logger ----------
		log = new Log(0, 4, width, getLogHeight());
		ui.add(log);	
		#end	

		// ------- login area --------
		nameInput = new NameInput(0, getLogHeight()+8, width, 90, connect);
		ui.add(nameInput);
		nameInput.setInputFocus();	

		// -------- chat area ---------
		chat = new Chat(0, getLogHeight()+8 + nameInput.height + 4, width, height-getLogHeight()-nameInput.height-8-4, onChatInput);
		ui.add(chat);

		// ----------------------------
		// ----- peote-net client -----
		// ----------------------------

		client = new Client(Config.host, Config.port, Config.channel, chat.say, this.say, chat.userEnter, chat.userLeave);
	}

	public function say(s:String, clear = false)
	{
		#if clientLogArea
		log.say(s, clear);
		#else
		trace(s);
		#end
	}

	public function connect(nickName:String)
	{	
		this.nickName = nickName;
		
		hideNameInput();

		// without Timer here it could block the ui changes above (on native targets)
		#if html5
		client.connect(onConnect, onDisconnect, onError);
		#else
		haxe.Timer.delay(()->client.connect(onConnect, onDisconnect, onError),100);
		#end
	}

	public function onConnect()
	{	
		client.setNickName(nickName);
		chat.enableInput();
	}

	public function onDisconnect(reason:Reason)
	{	
		chat.disableInput();
		chat.say('DISCONNECT (${reason.toString()}): chat-server closed\n');
		if (onMissingServer == null) showNameInput();
		else haxe.Timer.delay(() -> {
			onMissingServer(); // callback to start server into background
			showNameInput();
		},2000);
	}

	public function onError(reason:Reason)
	{	
		chat.disableInput();
		showNameInput();
		if (reason == Reason.KICK) chat.say('Nickname already exists\n');
		else chat.say('ERROR (${reason.toString()}): can\'t connect or lost connection to host\n');
	}

	public function showNameInput() {		
		chat.y = getLogHeight()+8 + nameInput.height+4;
		chat.height = ui.height-getLogHeight()-8 - nameInput.height-4;
		chat.updateLayout();

		nameInput.show();
		nameInput.updateLayout(); // if there was a window resize inbetween
		nameInput.setInputFocus();
	}

	public function hideNameInput() {
		nameInput.hide();
		chat.y = getLogHeight()+8;
		chat.height = ui.height-getLogHeight()-8;
		chat.updateLayout();
	}

	public function onChatInput(msg:String)
	{	
		if ( !command(msg) ) 
		{
			client.send(msg);

			// put it into own chat-output also ! ( syncORDER can diff to what others sees !!! :)
			chat.say(msg, nickName);
		}
	}
	
	public function command(msg:String):Bool
	{
		return switch (msg) {
			case "/who":
				var noUsers = true;
				for (nick in client.userNick) {
					chat.say(nick);
					noUsers = false;
				}
				if (noUsers) chat.say("No others are logged in.\n");
				else chat.say("are logged in.\n");
				true;
			default: false;
		}
	}
	

	// ---------------------------------------------------------
	// ---------------- resizing window ------------------------
	// ---------------------------------------------------------

	inline function getLogHeight():Int
		#if clientLogArea 
		return Std.int(ui.height * 0.2);
		#else
		return 0;
		#end

	public function resize(x:Int, y:Int, w:Int, h:Int) {
		if (ui != null) {
			ui.x = x;
			ui.y = y;
			ui.width = w;
			ui.height = h;
			
			#if clientLogArea
			log.width = w;
			log.height = getLogHeight();
			log.updateLayout();
			#end

			nameInput.width = w;
			// nameInput.height = ui.height-getLogHeight();
			nameInput.y = getLogHeight()+8;
			nameInput.updateLayout();

			chat.width = w;
			chat.height = ui.height-getLogHeight()-8 -((nameInput.isVisible) ? nameInput.height + 4 : 0);
			chat.y = getLogHeight()+8 + ((nameInput.isVisible) ? nameInput.height+4 : 0);
			chat.updateLayout();
		}
	}

} 