package;

import peote.net.Remote;
import ClientRemote;

import peote.io.UInt16;
import peote.io.Byte;

class ServerRemote implements Remote {
	
	var server:Server;
	public var userNr:Int;
	
	//var client:ClientRemoteRemoteServer = null; // <- problem with Remote macro (type can not be ready generated)!
	@:isVar public var client(get, set) = null;
	inline function get_client() return (client:ClientRemoteRemoteServer);
	inline function set_client(c) return client = (c:ClientRemoteRemoteServer);
	
	public function new( server:Server, userNr:Int) {
		this.server = server;
		this.userNr = userNr;
	}
	
	public function clientRemoteIsReady( client ) {
		// trace(Type.typeof(client));
		this.client = client;
		
		// send to all clients
		for (serverRemote in server.serverRemoteArray) {
			// add other pens to new clients
			if (serverRemote.userNr != userNr) client.addPen(serverRemote.userNr);
			
			// add new user per to other clients
			serverRemote.client.addPen(userNr);
		}
	}
	
	
	// ------------------------------------------------------------
	// ----- Functions that run on Server and called by Client ----
	// ------------------------------------------------------------
	
	@:remote public function penMove(mouseQueue:Array<UInt16>):Void {
		// trace('Server: penMove - userNr:$userNr');
		
		// send to all clients
		for (serverRemote in server.serverRemoteArray) {
			
			//if (serverRemote.client != null) serverRemote.client.penMove(userNr & 0xFF, mouseQueue);
			if (serverRemote.client != null) serverRemote.client.penMove(userNr, mouseQueue);
		}
	}

}