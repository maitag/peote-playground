package;

import peote.net.PeoteServer;
import peote.net.Remote;

import peote.io.Byte;
import peote.io.UInt16;
import peote.io.Int16;
import peote.io.Int32;
import peote.io.Double;


class Server implements Remote 
{
	var peoteServer:PeoteServer;

	public function new(host:String, port:Int, channelName:String, offline:Bool = false) 
	{
		peoteServer = new PeoteServer(
		{
			// bandwith simmulation if there is local testing
			#if ((!server) && (!client))
			offline : offline, // emulate network (to test locally without peote-server)
			netLag  : 10, // results in 20 ms per chunk
			netSpeed: 1024 * 1024 * 512, //[512KB] per second
			#end
			
			onCreate: function(server:PeoteServer)
			{
				trace('onCreateJoint: Channel ${server.jointNr} created.');
			},
			onUserConnect: function(server:PeoteServer, userNr:Int)
			{
				trace('onUserConnect: jointNr:${server.jointNr}, userNr:$userNr');
				
				server.setRemote(userNr, this, 0); // --> Client's onRemote on will be called with remoteId 0
				
			},
			onRemote: function(server:PeoteServer, userNr:Int, remoteId:Int)
			{
				trace('Server onRemote: jointNr:${server.jointNr}, userNr:$userNr, remoteId:$remoteId');
				
				var client = Client.getRemoteServer(server, userNr, remoteId);
				client.hello();

			},
			onUserDisconnect: function(server:PeoteServer, userNr:Int, reason:Int)
			{
				trace('onUserDisconnect: jointNr:${server.jointNr}, userNr:$userNr');
			},
			onError: function(server:PeoteServer, userNr:Int, reason:Int)
			{
				trace('onCreateJointError:$reason, userNr:$userNr');
			}
			
		});
		
		
		// create server
		peoteServer.create(host, port, channelName);
		
	}

	
	
	
	
	
	// ----- functions that run on Server and called by Client
	
	@:remote public function hello():Void {
		trace("Hello at Serverside");
	}
	

}