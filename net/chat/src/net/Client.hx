package net;

import peote.net.PeoteClient;

class Client {
	
	var peoteClient:PeoteClient;
	var clientRemote:ClientRemote;
	
	public var log:String->?Bool->Void;	

	public function new(host:String, port:Int, channelName:String, log:String->?Bool->Void) 
	{
		this.log = log;
		
		peoteClient = new PeoteClient(
		{
			onEnter: function(client:PeoteClient)
			{
				log('onEnterJoint: Joint number ${client.jointNr} entered');
				clientRemote = new ClientRemote(this);
				client.setRemote(clientRemote, 0);  // --> Server's onRemote will be called with remoteId 0
			},
			
			onRemote: function(client:PeoteClient, remoteId:Int)
			{
				log('Client onRemote: jointNr:${client.jointNr}, remoteId:$remoteId');
				clientRemote.serverRemoteIsReady(ServerRemote.getRemoteClient(client, remoteId));
			},
			
			onDisconnect: function(client:PeoteClient, reason:Int)
			{
				log('onDisconnect: jointNr=${client.jointNr}');
			},
			
			onError: function(client:PeoteClient, reason:Int)
			{
				log('onEnterJointError:$reason');
			}
			
		});		
		
		// enter server
		peoteClient.enter(host, port, channelName);
	}

}


