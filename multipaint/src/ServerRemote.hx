package;

import peote.net.Remote;
import ClientRemote;

class ServerRemote implements Remote {
	
	var server:Server;
	var userNr:Int;
	
	//var client:ClientRemoteRemoteServer = null;
	var client = null;
	
	public function new( server:Server, userNr:Int) {
		this.server = server;
		this.userNr = userNr;
	}
	
	public function clientRemoteIsReady( client ) {
		trace(Type.typeof(client));
		this.client = (client:ClientRemoteRemoteServer);
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

}