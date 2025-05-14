package net;

import peote.net.Remote;

import net.ClientRemote; // needs hack here (see below)

class ServerRemote implements Remote {
	
	var server:Server;
	var userNr:Int;

	//var client:ClientRemoteRemoteServer = null;	
	// needs hack here because the type "ClientRemoteRemoteServer" could not be generated at this time
	var client = (null : ClientRemoteRemoteServer);
	
	public inline function clientRemoteIsReady( client ) {
		//trace(Type.typeof(client));
		this.client = client;
		client.hello();
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
	
	@:remote public function hello():Void {
		log('Hello from client $userNr');		
		if (client != null) client.message("good morning client");
	}

	@:remote public function message(msg:String):Void {
		log('Message from client $userNr: $msg');
	}

}

