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

	public function new(peoteView:PeoteView, x:Int, y:Int, width:Int, height:Int)
	{
		this.peoteView = peoteView;

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

		client = new Client(Config.host, Config.port, Config.channel, chat.say, this.say);
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
		
		client.connect(onConnect, onDisconnect, onError);
		nameInput.hide();
	}

	public function onConnect()
	{	
		chat.say("connection established \\o/\n");
		client.setNickName(nickName);

		chat.y = getLogHeight()+8;
		chat.height = ui.height-getLogHeight()-8;
		chat.updateLayout();

		chat.showInput();
	}

	public function onDisconnect(reason:Reason)
	{	
		chat.y = getLogHeight()+8 + nameInput.height+4;
		chat.height = ui.height-getLogHeight()-8 - nameInput.height-4;
		chat.updateLayout();

		chat.hideInput();

		chat.say('DISCONNECT (${reason.toString()}): chat-server closed\n');

		nameInput.show();
		nameInput.updateLayout(); // if there was a window resize inbetween
		nameInput.setInputFocus();
	}

	public function onError(reason:Reason)
	{	
		// Halfwheat, i am sooo soo sory :). . . that this all not works in html5 yet -_-
		#if !html5
		chat.y = getLogHeight()+8 + nameInput.height+4;
		chat.height = ui.height-getLogHeight()-8 - nameInput.height-4;
		chat.updateLayout();

		chat.hideInput();

		chat.say('ERROR (${reason.toString()}): can\'t connect or lost connection to host\n');

		nameInput.show();
		nameInput.updateLayout(); // if there was a window resize inbetween
		nameInput.setInputFocus();
		#end
	}

	public function onChatInput(msg:String)
	{	
		client.send(msg);

		// put it into own chat-output also ! ( syncORDER can diff to what others sees !!! :)
		chat.say(msg,nickName);
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