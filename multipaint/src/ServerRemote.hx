package;

import peote.net.Remote;
import ClientRemote;

import peote.io.UInt16;

class ServerRemote implements Remote {
	
	var server:Server;
	var userNr:Int;
	
	//var client:ClientRemoteRemoteServer = null; // <- problem with Remote macro (type can not be ready generated)!
	@:isVar var client(get, set) = null;
	inline function get_client() return (client:ClientRemoteRemoteServer);
	inline function set_client(c) return client = (c:ClientRemoteRemoteServer);
	
	public function new( server:Server, userNr:Int) {
		this.server = server;
		this.userNr = userNr;
	}
	
	public function clientRemoteIsReady( client ) {
		// trace(Type.typeof(client));
		this.client = client;
		client.hello();
	}
	
	
	// ------------------------------------------------------------
	// ----- Functions that run on Server and called by Client ----
	// ------------------------------------------------------------
	
	@:remote public function hello():Void {
		trace('Hello from client $userNr');
		
		if (client != null) client.message("good morning client");
	}

	@:remote public function message(msg:String):Void {
		trace('Message from client $userNr: $msg');
	}

	@:remote public function penMove(mouseQueue:Array<UInt16>):Void {
		// trace('client $userNr: penMove $mouseQueue');
		
		// send to all clients
		for (serverRemote in server.serverRemoteArray) {
			
			if (serverRemote.client != null) serverRemote.client.penMove(mouseQueue);
		}
	}

}