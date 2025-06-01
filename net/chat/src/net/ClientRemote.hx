package net;

import peote.net.Remote;

import net.ServerRemote; // needs hack here (see below)

@:access(net.Client)
class ClientRemote implements Remote {
	
	var client:Client;	
		
	//public var server:ServerRemoteRemoteClient = null;	
	// needs hack here because the type "ServerRemoteRemoteClient" could not be generated at this time
	public var server = (null : ServerRemoteRemoteClient);
	
	public inline function serverRemoteIsReady( server ) {
		//trace(Type.typeof(server));
		this.server = server;
	}
	
	// ------------------------------------------------------------

	public function new( client:Client ) {		
		this.client = client;
	}
	
	inline function log(s:String, ?clear:Bool) client.log(s, clear);
	
	// ------------------------------------------------------------
	// ----- Functions that run on Client and called by Server ----
	// ------------------------------------------------------------
	
	@:remote public function wrongNickName():Void {
		log('nickname already exists');
		client.wrongNickName();
	}
	
	@:remote public function userList(nickNames:Map<Int,String>):Void {
		log('client gets user list');
		client.userList(nickNames);
	}
	
	@:remote public function userMessage(userNr:Int, msg:String):Void {
		// log('Message from server: $msg');
		client.userMessage(userNr, msg);
	}

	@:remote public function userEnter(userNr:Int, nick:String):Void {
		log('new user "$nick" ($userNr) enters server');
		client.userEnter(userNr, nick);
	}

	@:remote public function userLeave(userNr:Int):Void {
		log('user $userNr leaves server');
		client.userLeave(userNr);
	}

	@:remote public function userSetNickName(userNr:Int, nick:String):Void {
		log('client "$nick" ($userNr) changes nickname into -> $nick');
		client.userSetNickName(userNr, nick);
	}

}
