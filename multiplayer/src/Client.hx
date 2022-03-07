package;

import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

import peote.net.PeoteClient;

class Client 
{

	var peoteClient:PeoteClient;
	
	public function new(window:Window, host:String, port:Int, channelName:String) 
	{
		peoteClient = new PeoteClient(
		{
			onEnter: function(client:PeoteClient)
			{
				trace('onEnterJoint: Joint number ${client.jointNr} entered');
				
				// TODO: into ClientView !
				var peoteView = new PeoteView(window);

				var buffer = new Buffer<Sprite>(4, 4, true);
				var display = new Display(10, 10, window.width - 20, window.height - 20, Color.GREEN);
				var program = new Program(buffer);

				peoteView.addDisplay(display);
				display.addProgram(program);

				var sprite = new Sprite();
				buffer.addElement(sprite);
				
/*				// first client object where methods can be called by remote
				var clientFunctions = new FirstClientFunctions();
				clientFunctions.message = function(s:String) {
					out.log('first clientobject -> message("$s")');
				};				
				client.setRemote(clientFunctions, FirstClientFunctions.remoteId);       // --> Server's onRemote on will be called with 0
				
				// second client object where methods can be called by remote
				var secondClientFunctions = new SecondClientFunctions();
				secondClientFunctions.test = function() {
					out.log('second clientobject -> test()');
				};				
				client.setRemote(secondClientFunctions, SecondClientFunctions.remoteId);  // --> Server's onRemote on will be called with 1
*/				
			},
			onRemote: function(client:PeoteClient, remoteId:Int)
			{
				trace('onRemote: jointNr:${client.jointNr}, remoteId:$remoteId');
				
/*				var serverFunctions = ServerFunctions.getRemoteClient(client, remoteId);
				
				// call ServerFunctions
				serverFunctions.message("hello from client", true);
				haxe.Timer.delay( function() {
					serverFunctions.test();
				}, 3000);
				serverFunctions.numbers(255, 0xFFFF, 0x7FFF, 0x7FFFFFFF, 0x7FFFFFFF, 1.2345678901234, 1.2345678901234 );
				
				var v = new Vector<Array<Int>>(3);
				v[0] = [1, 2];
				v[1] = [3, 4, 5];
				v[2] = null; // null will result on remote in an empty Array
				serverFunctions.complex(Bytes.ofString("dada"), v); 
				
				var list = new List<Int>(); for (i in 0...5) list.add(i);
				serverFunctions.lists(list); // null will result on remote in an empty List 
				
				//var m:IntMap< haxe.ds.StringMap< Array<Int>> > = [
				var m = [
					1 => ["a1" => [10,11], "b1" => [12,13]],
					2 => ["a2" => [20, 21], "b2" => [22, 23]],
					7 => null // null will result on remote in an empty Map
				];
				serverFunctions.maps(m);
				
				var u = new User("Alice", 42, "test");
				serverFunctions.hxbit(u);
				
				var m:Message = {name:"Klaus", age:23};
				serverFunctions.msgpackTyped(m);
				
				serverFunctions.msgpack({name:"Bob", age:48, friends:["Mary","Johan"]});
*/			

			},
			onDisconnect: function(client:PeoteClient, reason:Int)
			{
				trace('onDisconnect: jointNr=${client.jointNr}');
			},
			onError: function(client:PeoteClient, reason:Int)
			{
				trace('onEnterJointError:$reason');
			}
		});
		
		
		// enter server
		peoteClient.enter(host, port, channelName);

	}
	
/*
// functions that run on Client
class FirstClientFunctions implements Remote {
	public inline static var remoteId = 0;
	@:remote public var message:String->Void;
}
class SecondClientFunctions implements Remote {
	public inline static var remoteId = 1;
	@:remote public var test:Void->Void;
}
*/	


	// ------------------------------------------------------------
	// ------------ Delegated LIME EVENTS -------------------------
	// ------------------------------------------------------------	


}