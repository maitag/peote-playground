package net;

import peote.net.PeoteClient;

class Client {
	
	var peoteClient:PeoteClient;
	var clientRemote:ClientRemote;
	
	public function new(host:String, port:Int, channelName:String) 
	{
		peoteClient = new PeoteClient(
		{
			onEnter: function(client:PeoteClient)
			{
				trace('onEnterJoint: Joint number ${client.jointNr} entered');
				clientRemote = new ClientRemote(this);
				client.setRemote(clientRemote, 0);  // --> Server's onRemote will be called with remoteId 0
			},
			
			onRemote: function(client:PeoteClient, remoteId:Int)
			{
				trace('Client onRemote: jointNr:${client.jointNr}, remoteId:$remoteId');
				clientRemote.serverRemoteIsReady(ServerRemote.getRemoteClient(client, remoteId));
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


