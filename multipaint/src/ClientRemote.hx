package ;

import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

import peote.net.Remote;
import ServerRemote;

// ----- functions that run on Client and called by Server ----
class ClientRemote implements Remote {
	
	var client:Client;
	
	//public var server:ServerRemoteRemoteClient = null;
	public var server = null;
	
	public function new( window:Window, client:Client ) {
		
		this.client = client;
		
		// delegate Lime mouse and keyboard events
		
		// TODO
		
		
		// initialize peote-view
		
		// TODO
		var peoteView = new PeoteView(window);

		var buffer = new Buffer<Sprite>(4, 4, true);
		var display = new Display(10, 10, window.width - 20, window.height - 20, Color.GREEN);
		var program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);

		var sprite = new Sprite();
		buffer.addElement(sprite);
				
	}
	
	public function serverRemoteIsReady( server ) {
		trace(Type.typeof(server));
		this.server = (server:ServerRemoteRemoteClient);
		server.hello();
	}
	
	
	// ------------------------------------------------------------
	// ------------ Delegated LIME EVENTS -------------------------
	// ------------------------------------------------------------	

	public function onMouseMove(x:Float, y:Float) {
		// TODO
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
