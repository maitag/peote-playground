package net;

import peote.net.Remote;

import net.ClientRemote; // needs hack here (see below)

@:access(net.Server)
class ServerRemote implements Remote {
	
	var server:Server;
	public var userNr(default, null):Int;
	public var nick(default, null):String = "";

	//var client:ClientRemoteRemoteServer = null;	
	// needs hack here because the type "ClientRemoteRemoteServer" could not be generated at this time
	public var client(default, null) = (null : ClientRemoteRemoteServer);
	
	public inline function clientRemoteIsReady( client ) {
		//trace(Type.typeof(client));
		this.client = client;
	}
	
	// ------------------------------------------------------------

	public function new( server:Server, userNr:Int) {
		this.server = server;
		this.userNr = userNr;
	}
	
	inline function log(s:String, ?clear:Bool) server.log(s, clear);
	
	
	// ------------------------------------------------------------
	// ----- Functions that run on Server and called by Client ----
	// ------------------------------------------------------------

	@:remote public function message(msg:String):Void {
		log('Message from ${server.serverRemote.get(userNr).nick} ($userNr): $msg');

		// call userMessage on all clients (excluding the sender)
		for (remote in server.serverRemote)
		{
			if (remote.client != null && remote.userNr != userNr) {
				log('call "userMessage()" of client: "${remote.nick}" ($userNr)');
				remote.client.userMessage(userNr, msg);
			}
		}

	}

	@:remote public function setNickName(nick:String):Void {
		log('client "${this.nick}" ($userNr) tryes to change nickname into -> $nick');
		
		// check nickname:
		var wrongNick = false;
		
		if (nick.length < 2 || nick != cleanNickName(nick)) wrongNick = true;
		else {
			// check if nickname already taken
			for (remote in server.serverRemote)
			{
				if (nick == remote.nick) {
					wrongNick = true;
					break;
				}
			}
		}

		if (wrongNick) {
			// call "wrongNickName()" back to the client!
			client.wrongNickName();
		}
		else {		
			// call userSetNickName on all clients (excluding the sender)
			for (remote in server.serverRemote)
			{
				if (remote.client != null && remote.userNr != userNr) {
					if (this.nick == "") {		
						log('call "userEnter()" of client: "${remote.nick}" ($userNr)');
						remote.client.userEnter(userNr, nick);
					}
					else {
						log('call "userSetNickName()" of client: "${remote.nick}" ($userNr)');
						remote.client.userSetNickName(userNr, nick);
					}
				}
			}

			this.nick = nick;


			// send map of all connected users and its nicknames:
			var nickNames = new Map<Int,String>();
			for ( remote in server.serverRemote) 
				if (remote.userNr != userNr) nickNames.set(remote.userNr, remote.nick);
			log('call "userList()" of client: $userNr');
			client.userList(nickNames);
		}

	}

	public function cleanNickName(s:String):String {
		s = ~/  +/g.replace(s, " "); // multiple spaces
		s = ~/^ /.replace(s, ""); // space at line start
		s = ~/ $/.replace(s, ""); // space at line end
		return s.substr(0, 23);
	}


}


