package client;

import lime.ui.Window;

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
	
	public function new( window:Window, client:Client ) {
		
		this.client = client;
		
		// initialize peote-view
		var peoteView = new PeoteView(window);

		var buffer = new Buffer<Sprite>(4, 4, true);
		var display = new Display(10, 10, window.width - 20, window.height - 20, Color.GREEN);
		var program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);

		var sprite = new Sprite();
		buffer.addElement(sprite);
				
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
