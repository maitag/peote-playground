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
	
	
	// ------------------------------------------------------------
	// ----- Functions that run on Client and called by Server ----
	// ------------------------------------------------------------
	
	@:remote public function hello():Void {
		trace('Hello from server');		
		if (server != null) server.message("good morning server");
	}

	@:remote public function message(msg:String):Void {
		trace('Message from server: $msg');
	}

}
