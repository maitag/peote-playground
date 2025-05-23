package net;

import haxe.ds.IntMap;
import peote.net.PeoteServer;
import peote.net.Reason;

class Server
{
	var peoteServer:PeoteServer;
	var serverRemote = new IntMap<ServerRemote>();

	// callbacks:
	var log:String->?Bool->Void;	

	public function new(host:String, port:Int, channel:String, log:String->?Bool->Void, offline:Bool = false) 
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
				log('Channel number ${server.jointNr} created.');
			},
			
			onUserConnect: function(server:PeoteServer, userNr:Int)
			{
				log('User Connect: channel number:${server.jointNr}, userNr:$userNr');
				
				// store a new ServerRemote for each user into Map
				var _serverRemote = new ServerRemote(this, userNr);
				serverRemote.set(userNr, _serverRemote);
				
				server.setRemote(userNr, _serverRemote, 0); // --> Client's onRemote on will be called with remoteId 0				
			},
			
			onRemote: function(server:PeoteServer, userNr:Int, remoteId:Int)
			{
				log('Server remote: channel number:${server.jointNr}, userNr:$userNr, remoteId:$remoteId');
				serverRemote.get(userNr).clientRemoteIsReady( ClientRemote.getRemoteServer(server, userNr, remoteId) );
			},
			
			onUserDisconnect: function(server:PeoteServer, userNr:Int, reason:Reason)
			{
				log('User Disconnect: channel number:${server.jointNr}, userNr:$userNr');
				serverRemote.remove(userNr);

				// call userLeave on all clients
				for (remote in serverRemote) {
					if (remote.client != null && remote.userNr != userNr) {
						log('call "userLeave()" of client: "${remote.nick}" ($userNr)');
						remote.client.userLeave(userNr);
					}
				}
			},
			
			onError: function(server:PeoteServer, userNr:Int, reason:Reason)
			{
				log('Error:$reason, userNr:$userNr');
				serverRemote.remove(userNr);

				// call userLeave on all clients
				for (remote in serverRemote) {
					if (remote.client != null && remote.userNr != userNr) {
						log('call "userLeave()" of client: "${remote.nick}" ($userNr)');
						remote.client.userLeave(userNr);
					}
				}
			}			
		});
				
		// create server
		log('try to connect to $host:$port\ncreate channel "$channel" ...');
		peoteServer.create(host, port, channel);		
	}	

}

