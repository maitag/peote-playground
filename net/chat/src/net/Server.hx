package net;

import haxe.ds.IntMap;
import peote.net.PeoteServer;

class Server
{
	var peoteServer:PeoteServer;
	var serverRemote = new IntMap<ServerRemote>();

	public var log:String->?Bool->Void;	

	public function new(host:String, port:Int, channelName:String, log:String->?Bool->Void, offline:Bool = false) 
	{
		this.log = log;

		peoteServer = new PeoteServer(
		{
			// bandwith simmulation if there is local testing
			offline : offline, // emulate network (to test locally without peote-server)
			netLag  : 10, // results in 20 ms per chunk
			netSpeed: 1024 * 1024 * 512, //[512KB] per second
			
			onCreate: function(server:PeoteServer)
			{
				log('onCreateJoint: Channel ${server.jointNr} created.');
			},
			
			onUserConnect: function(server:PeoteServer, userNr:Int)
			{
				log('onUserConnect: jointNr:${server.jointNr}, userNr:$userNr');
				
				// store a new ServerRemote for each user into Map
				var _serverRemote = new ServerRemote(this, userNr);
				serverRemote.set(userNr, _serverRemote);
				
				server.setRemote(userNr, _serverRemote, 0); // --> Client's onRemote on will be called with remoteId 0				
			},
			
			onRemote: function(server:PeoteServer, userNr:Int, remoteId:Int)
			{
				log('Server onRemote: jointNr:${server.jointNr}, userNr:$userNr, remoteId:$remoteId');
				serverRemote.get(userNr).clientRemoteIsReady( ClientRemote.getRemoteServer(server, userNr, remoteId) );
			},
			
			onUserDisconnect: function(server:PeoteServer, userNr:Int, reason:Int)
			{
				log('onUserDisconnect: jointNr:${server.jointNr}, userNr:$userNr');
				//serverRemote.get(userNr) = null;
			},
			
			onError: function(server:PeoteServer, userNr:Int, reason:Int)
			{
				log('onCreateJointError:$reason, userNr:$userNr');
				//serverRemote.get(userNr) = null;
			}
			
		});
				
		// create server
		peoteServer.create(host, port, channelName);		
	}	

}

