package server;

import View;
import peote.net.PeoteServer;
import peote.net.Remote;

import client.*; // needs hack here (see below)

class User implements Remote {
	
	public var server:Server;
	public var userNr:Int;
	
	// var remoteView:ViewRemoteServer = null;	
	// needs hack here because the type "ClientRemoteRemoteServer" could not be generated at this time
	var remoteView = (null : ViewRemoteServer);
	
	public inline function remoteIsReady( server:PeoteServer, userNr:Int, remoteId:Int ) {
		switch (remoteId) {
			case 0:	remoteView = View.getRemoteServer(server, userNr, remoteId);
					remoteView.hello();
			default: trace("unknow remote ID");
		}
	}
	
	// ------------------------------------------------------------
	// ---------------------- CONSTRUCTOR -------------------------
	// ------------------------------------------------------------
	
	public function new( server:Server, userNr:Int) {
		this.server = server;
		this.userNr = userNr;
	}
	
	
	// ------------------------------------------------------------
	// ----- Functions that run on Server and called by Client ----
	// ------------------------------------------------------------
	
	@:remote public function hello():Void {
		trace('Hello from client $userNr');		
		if (remoteView != null) remoteView.message("good morning client");
	}

	@:remote public function message(msg:String):Void {
		trace('Message from client $userNr: $msg');
	}

}

