package server;

import haxe.ds.IntMap;
import peote.net.PeoteServer;

class Server
{
	public var peoteServer:PeoteServer;
	public var users = new IntMap<User>();

	public function new(host:String, port:Int, channelName:String, offline:Bool = false) 
	{
		peoteServer = new PeoteServer(
		{
			// bandwith simmulation if there is local testing
			offline : offline, // emulate network (to test locally without peote-server)
			netLag  : 10, // results in 20 ms per chunk
			netSpeed: 1024 * 1024 * 512, //[512KB] per second
			
			onCreate: function(server:PeoteServer)
			{
				trace('onCreateJoint: Channel ${server.jointNr} created.');
			},
			
			onUserConnect: function(server:PeoteServer, userNr:Int)
			{
				trace('onUserConnect: jointNr:${server.jointNr}, userNr:$userNr');
				
				// store a new ServerRemote for each user into Map
				var user = new User(this, userNr);
				users.set(userNr, user);
				
				server.setRemote(userNr, user, 0); // --> Client's onRemote on will be called with remoteId 0				
			},
			
			onRemote: function(server:PeoteServer, userNr:Int, remoteId:Int)
			{
				trace('Server onRemote: jointNr:${server.jointNr}, userNr:$userNr, remoteId:$remoteId');
				users.get(userNr).remoteIsReady( server, userNr, remoteId );
			},
			
			onUserDisconnect: function(server:PeoteServer, userNr:Int, reason:Int)
			{
				trace('onUserDisconnect: jointNr:${server.jointNr}, userNr:$userNr');
				//users.get(userNr) = null;
			},
			
			onError: function(server:PeoteServer, userNr:Int, reason:Int)
			{
				trace('onCreateJointError:$reason, userNr:$userNr');
				//users.get(userNr) = null;
			}
			
		});
				
		// create server
		peoteServer.create(host, port, channelName);		
	}	

}

