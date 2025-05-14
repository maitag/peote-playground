package net;

import peote.net.Remote;

import net.ServerRemote; // needs hack here (see below)

class ClientRemote implements Remote {
	
	var client:Client;	
		
	//public var server:ServerRemoteRemoteClient = null;	
	// needs hack here because the type "ServerRemoteRemoteClient" could not be generated at this time
	public var server = (null : ServerRemoteRemoteClient);
	
	public inline function serverRemoteIsReady( server ) {
		//trace(Type.typeof(server));
		this.server = server;
		server.hello();
	}
	
	// ------------------------------------------------------------

	public function new( client:Client ) {		
		this.client = client;
	}
	
	inline function log(s:String, ?clear:Bool) client.log(s, clear);
	
	// ------------------------------------------------------------
	// ----- Functions that run on Client and called by Server ----
	// ------------------------------------------------------------
	
	@:remote public function hello():Void {
		log('Hello from server');		
		if (server != null) server.message("good morning server");
	}

	@:remote public function message(msg:String):Void {
		log('Message from server: $msg');
	}

}
