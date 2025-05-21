package net;

import peote.net.PeoteClient;
import peote.net.Reason;

@:publicFields
class Client {
	
	var peoteClient:PeoteClient;
	var clientRemote:ClientRemote;

	var host:String;
	var port:Int;
	var channel:String;
	
	// callbacks:
	var log:String->?Bool->Void;
	var onRemoteReady:Void->Void;
	var onDisconnect:Void->Void;
	
	var onClientEnter:String->?Bool->Void;
	var onClientMessage:String->?Bool->Void;


	public function new(host:String, port:Int, channel:String, log:String->?Bool->Void) 
	{
		this.host = host;
		this.port = port;
		this.channel = channel;

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

				onRemoteReady(); // <-- callback to View
			},
			
			onDisconnect: function(client:PeoteClient, reason:Reason)
			{
				log('Disconnect:$reason, channel number=${client.jointNr}');

				onDisconnect(); // <-- callback to View
			},
			
			onError: function(client:PeoteClient, reason:Reason)
			{
				log('Error:$reason');

				onDisconnect(); // <-- callback to View
			}			
		});		
	}
	
	public function connect(onRemoteReady:Void->Void, onDisconnect:Void->Void)
	{
		this.onRemoteReady = onRemoteReady;
		this.onDisconnect = onDisconnect;

		// enter server
		log('try to connect to $host:$port\nenter channel "$channel" ...');
		peoteClient.enter(host, port, channel);
	}

	public function setNickName(s:String) {
		clientRemote.server.setNickName(s);
	}

	public function send(msg:String) {
		clientRemote.server.message(msg);
	}
}


