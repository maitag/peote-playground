package ;

import peote.net.Remote;
import ServerRemote;

import peote.io.Byte;
import peote.io.UInt16;

#if lime
import haxe.ds.IntMap;
import haxe.ds.Vector;
import lime.ui.Window;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;


class ClientRemote implements Remote {
	
	var client:Client;
	
	
	var peoteView:PeoteView;
	var display:Display;
	var buffer:Buffer<Sprite>;
	var program:Program;
	
	//public var server:ServerRemoteRemoteClient = null; // <- problem with Remote macro (type can not be ready generated)!
	@:isVar var server(get, set) = null;
	inline function get_server() return (server:ServerRemoteRemoteClient);
	inline function set_server(s) return server = (s:ServerRemoteRemoteClient);
	
	public function new( window:Window, client:Client ) {
		
		this.client = client;
		
		// delegate Lime mouse and keyboard events		
		window.onMouseMove.add(mouseMove);
		window.onMouseUp.add(mouseUp);
		window.onMouseDown.add(mouseDown);
		window.onMouseWheel.add(mouseWheel);
		//window.onKeyDown.add(keyDownActive);
		//window.onKeyDown.add(keyUpActive);		
		
		// initialize peote-view
		
		// TODO
		peoteView = new PeoteView(window);

		buffer = new Buffer<Sprite>(4, 4, true);
		display = new Display(0, 0, window.width, window.height, Color.GREEN);
		program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);

	}
	
	public function serverRemoteIsReady( server ) {
		// trace(Type.typeof(server));
		this.server = server;
		//server.hello();
	}
	
	
	// ------------------------------------------------------------
	// ------------ Delegated LIME EVENTS -------------------------
	// ------------------------------------------------------------	

	var mouseQueue = new Array<UInt16>();
	var mouseQueueTime:Float = 0;
		
	inline function mouseMove(x:Float, y:Float) {
		//trace("mouseMove", x, y);
		if (haxe.Timer.stamp() < mouseQueueTime) {
			//trace("queue");
			mouseQueue.push(Std.int(x));
			mouseQueue.push(Std.int(y));
		}
		else {
			mouseQueueTime = haxe.Timer.stamp() + 0.02;			
			if (mouseQueue.length != 0 && server != null) {
				//trace("send");
				server.penMove(mouseQueue);
				mouseQueue.resize(0);
			}
		}
		
	}
	inline function mouseDown(x:Float, y:Float, button:MouseButton) {
		trace("mouseDown", x, y, button);
	}
	inline function mouseUp(x:Float, y:Float, button:MouseButton) {
		trace("mouseUp", x, y, button);
	}
	inline function mouseWheel(dx:Float, dy:Float, mode:MouseWheelMode) {
		trace("mouseUp",dx, dy, mode);
	}
			
	
	
	// ------------------------------------------------------------
	// ----- Functions that run on Client and called by Server ----
	// ------------------------------------------------------------
	
/*	@:remote public function hello():Void {
		trace('Hello from server');
		
		if (server != null) server.message("good morning server");
	}

	@:remote public function message(msg:String):Void {
		trace('Message from server: $msg');
	}
*/	
	
	var penMap = new IntMap<Sprite>();

	@:remote public function addPen(userNr:UInt16):Void {
		trace('Client: addPen - userNr:$userNr');
		
		var sprite = new Sprite();
		buffer.addElement(sprite);
		
		penMap.set(userNr, sprite);
	}
	
	@:remote public function removePen(userNr:UInt16):Void {
		trace('Client: removePen - userNr:$userNr');
		
		var sprite = penMap.get(userNr);
		if (sprite != null) {
			buffer.removeElement(sprite);
			penMap.remove(userNr);
		}
	}
	
/*	@:remote public function changePen(userNr:UInt16, penParam:Int):Void {
		trace('Client: changePen - userNr:$userNr, penNr:$penNr');
		penMap.set(userNr, availPen.get(penNr));
	}
*/	
	@:remote public function penMove(userNr:UInt16, mouseQueue:Array<UInt16>):Void {
		//trace('Client: penMove - userNr:$userNr');
		
		// TODO: better into onRender
/*		for (i in 0...mouseQueue.length()) {
			
		}
*/		
		// at now only fetching the last value into mouseQueue
		var sprite = penMap.get(userNr);
		if (sprite != null) {
			sprite.y = mouseQueue.pop();
			sprite.x = mouseQueue.pop();
			buffer.updateElement(sprite);
		}
	}

}


#else

// need for dedicated server to build without lime
class ClientRemote implements Remote {
	@:remote public function addPen(userNr:UInt16):Void {}
	@:remote public function removePen(userNr:UInt16) {}
	@:remote public function penMove(userNr:UInt16, mouseQueue:Array<UInt16>) {}
}

#end