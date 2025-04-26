package;

import lime.ui.Window;
import peote.net.PeoteClient;
import peote.net.Reason;

class Client {
	
	var peoteClient:PeoteClient;
	
	var clientRemote:ClientRemote;
	
	public function new(window:lime.ui.Window, host:String, port:Int, channelName:String) 
	{
		peoteClient = new PeoteClient(
		{
			onEnter: function(client:PeoteClient)
			{
				trace('onEnterJoint: Joint number ${client.jointNr} entered');
				clientRemote = new ClientRemote(window, this);
				client.setRemote(clientRemote, 0);  // --> Server's onRemote will be called with remoteId 0
			},
			onRemote: function(client:PeoteClient, remoteId:Int)
			{
				trace('Client onRemote: jointNr:${client.jointNr}, remoteId:$remoteId');
				clientRemote.serverRemoteIsReady(ServerRemote.getRemoteClient(client, remoteId));				
			},
			onDisconnect: function(client:PeoteClient, reason:Reason)
			{
				trace('onDisconnect: jointNr=${client.jointNr}, reason:$reason');
			},
			onError: function(client:PeoteClient, reason:Reason)
			{
				trace('onEnterJointError:$reason');
			}
			
		});		
		
		// enter server
		peoteClient.enter(host, port, channelName);
	}
	
}


