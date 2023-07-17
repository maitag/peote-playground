package;

import Client;
import lime.ui.Window;

import ui.UI;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

import peote.net.PeoteClient;
import peote.net.Remote;

import server.*; // needs hack here (see below)

class View implements Remote {
	
	public var client:Client;
		
	//public var remoteUser:UserRemoteClient = null;	
	// needs hack here because the type "ServerRemoteRemoteClient" could not be generated at this time
	public var remoteUser = (null : UserRemoteClient);
	
	public inline function remoteIsReady( peoteClient:PeoteClient, remoteId:Int ) {
		switch (remoteId) {
			case 0:	remoteUser = User.getRemoteClient( peoteClient, remoteId);
					remoteUser.hello();
			default: trace("unknow remote ID");
		}
	}
	
	// ------------------------------------------------------------
	// ---------------------- CONSTRUCTOR -------------------------
	// ------------------------------------------------------------
	
	public function new( ui:UI, client:Client ) {
		
		this.client = client;
		
				
	}
		
	
	// ------------------------------------------------------------
	// ----- Functions that run on Client and called by Server ----
	// ------------------------------------------------------------
	
	@:remote public function hello():Void {
		trace('Hello from server');		
		if (remoteUser != null) remoteUser.message("good morning server");
	}

	@:remote public function message(msg:String):Void {
		trace('Message from server: $msg');
	}

}
