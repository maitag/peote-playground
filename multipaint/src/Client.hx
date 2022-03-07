package;

import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;

import peote.net.PeoteClient;
import peote.net.Remote;

class Client implements Remote
{

	var peoteClient:PeoteClient;
	
	public function new(window:Window, host:String, port:Int, channelName:String) 
	{
		peoteClient = new PeoteClient(
		{
			onEnter: function(client:PeoteClient)
			{
				trace('onEnterJoint: Joint number ${client.jointNr} entered');
				
				client.setRemote(this, 0);  // --> Server's onRemote will be called with remoteId 0

								
				// ----- TODO --------
				var peoteView = new PeoteView(window);

				var buffer = new Buffer<Sprite>(4, 4, true);
				var display = new Display(10, 10, window.width - 20, window.height - 20, Color.GREEN);
				var program = new Program(buffer);

				peoteView.addDisplay(display);
				display.addProgram(program);

				var sprite = new Sprite();
				buffer.addElement(sprite);
				

				
			},
			onRemote: function(client:PeoteClient, remoteId:Int)
			{
				trace('Client onRemote: jointNr:${client.jointNr}, remoteId:$remoteId');
				
				var server = Server.ServerFunctions.getRemoteClient(client, remoteId);
				
				// call ServerFunctions
				server.hello();
				
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

	
	
	
	
	// ----- functions that run on Client and called by Server ----

	@:remote public function hello():Void {
		trace("Hello at Clientside");
	}



	
	
	// ------------------------------------------------------------
	// ------------ Delegated LIME EVENTS -------------------------
	// ------------------------------------------------------------	


}


