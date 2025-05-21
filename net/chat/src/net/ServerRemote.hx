package net;

import peote.net.Remote;

import net.ClientRemote; // needs hack here (see below)

class ServerRemote implements Remote {
	
	var server:Server;
	var userNr:Int;
	var nick:String = "";

	//var client:ClientRemoteRemoteServer = null;	
	// needs hack here because the type "ClientRemoteRemoteServer" could not be generated at this time
	var client = (null : ClientRemoteRemoteServer);
	
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
		for (serverRemote in server.serverRemote)
		{
			if (serverRemote.client != null && serverRemote.userNr != userNr) {
				log('send to client: ${serverRemote.nick}');
				serverRemote.client.message(nick + ":" + msg);
			}
		}

	}

	@:remote public function setNickName(s:String):Void {
		log('client $userNr tryes to change nickname into -> $s');
		nick = s;
	}

}

