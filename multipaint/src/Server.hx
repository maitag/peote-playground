package;

import haxe.ds.IntMap;
import peote.net.PeoteServer;

class Server {
	
	var peoteServer:PeoteServer;
	
	public var serverRemoteMap(default, null) = new IntMap<ServerRemote>();
	public var serverRemoteArray(default, null) = new Array<ServerRemote>();

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
				
				// store a new ServerRemote for each user into serverRemoteMap
				var serverRemote = new ServerRemote(this, userNr);
				serverRemoteMap.set(userNr, serverRemote);
				
				// push into serverRemoteArray for faster access to all remotes
				serverRemoteArray.push(serverRemote);
				
				server.setRemote(userNr, serverRemote, 0); // --> Client's onRemote on will be called with remoteId 0				
			},
			onRemote: function(server:PeoteServer, userNr:Int, remoteId:Int)
			{
				trace('Server onRemote: jointNr:${server.jointNr}, userNr:$userNr, remoteId:$remoteId');
				serverRemoteMap.get(userNr).clientRemoteIsReady( ClientRemote.getRemoteServer(server, userNr, remoteId) );
			},
			onUserDisconnect: function(server:PeoteServer, userNr:Int, reason:Int)
			{
				trace('onUserDisconnect: jointNr:${server.jointNr}, userNr:$userNr');
				removeServerRemote(userNr);
			},
			onError: function(server:PeoteServer, userNr:Int, reason:Int)
			{
				trace('onCreateJointError:$reason, userNr:$userNr');
				removeServerRemote(userNr);
			}
			
		});
		
		// create server
		peoteServer.create(host, port, channelName);		
	}	
	
	function removeServerRemote(userNr) {
		
			var serverRemote = serverRemoteMap.get(userNr);
			if (serverRemote != null) 
			{
				serverRemoteMap.remove(userNr);
				serverRemoteArray.remove(serverRemote);
				serverRemote = null;
				
				// remove that pen from all clients
				for (serverRemote in serverRemoteArray) {
					if (serverRemote.client != null) serverRemote.client.removePen(userNr);
				}					
			}
	}
				

}

