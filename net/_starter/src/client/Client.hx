package client;

import lime.ui.Window;
import peote.net.PeoteClient;

class Client {
	
	public var peoteClient:PeoteClient;
	public var view:View;
	
	public function new(window:lime.ui.Window, host:String, port:Int, channelName:String) 
	{
		peoteClient = new PeoteClient(
		{
			onEnter: function(client:PeoteClient)
			{
				trace('onEnterJoint: Joint number ${client.jointNr} entered');
				view = new View(window, this);
				client.setRemote(view, 0);  // --> Server's onRemote will be called with remoteId 0
			},
			
			onRemote: function(client:PeoteClient, remoteId:Int)
			{
				trace('Client onRemote: jointNr:${client.jointNr}, remoteId:$remoteId');
				view.remoteIsReady(client, remoteId);
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

}


