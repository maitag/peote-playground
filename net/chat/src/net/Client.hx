package net;

import peote.net.PeoteClient;
import peote.net.Reason;

class Client {
	
	var peoteClient:PeoteClient;
	var clientRemote:ClientRemote;
	
	public var log:String->?Bool->Void;	

	public function new(host:String, port:Int, channel:String, log:String->?Bool->Void) 
	{
		this.log = log;
		
		peoteClient = new PeoteClient(
		{
			onEnter: function(client:PeoteClient)
			{
				log('Channel number ${client.jointNr} entered');
				clientRemote = new ClientRemote(this);
				client.setRemote(clientRemote, 0);  // --> Server's onRemote will be called with remoteId 0
			},
			
			onRemote: function(client:PeoteClient, remoteId:Int)
			{
				log('Client remote: channel number:${client.jointNr}, remoteId:$remoteId');
				clientRemote.serverRemoteIsReady(ServerRemote.getRemoteClient(client, remoteId));
			},
			
			onDisconnect: function(client:PeoteClient, reason:Reason)
			{
				log('Disconnect:$reason, channel number=${client.jointNr}');
			},
			
			onError: function(client:PeoteClient, reason:Reason)
			{
				log('Error:$reason');
			}
			
		});		
		
		// enter server
		log('try to connect to $host:$port\nenter channel "$channel" ...');
		peoteClient.enter(host, port, channel);
	}

}


