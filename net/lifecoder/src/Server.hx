package;

import haxe.ds.IntMap;
import peote.net.PeoteServer;
import peote.net.Remote;
import ui.UI;


import Client; // needs for RemoteGeneration

class Server
{
	public var peoteServer:PeoteServer;
	public var users = new IntMap<User>();
	public var ui:UI;

	public function new(ui:UI, host:String, port:Int, channelName:String, offline:Bool = false)
	{
		this.ui = ui;
		
		peoteServer = new PeoteServer(
		{
			// bandwith simmulation if there is local testing
			offline : offline, // emulate network (to test locally without peote-server)
			netLag  : 10, // results in 20 ms per chunk
			netSpeed: 1024 * 1024 * 512, //[512KB] per second
			
			onCreate: function(server:PeoteServer)
			{
				trace('onCreateJoint: Channel ${server.jointNr} created.');
				ui.createCodeEditor(true, onInsertText, onDeleteText);
			},
			
			onUserConnect: function(server:PeoteServer, userNr:Int)
			{
				trace('onUserConnect: jointNr:${server.jointNr}, userNr:$userNr');			
			},
			
			onRemote: function(server:PeoteServer, userNr:Int, remoteId:Int)
			{
				trace('Server onRemote: jointNr:${server.jointNr}, userNr:$userNr, remoteId:$remoteId');
				switch (remoteId) {
					case 0:	
						var user = new User(this, userNr, Client.getRemoteServer(server, userNr, remoteId));
						user.remoteClient.insert(0, 0, ui.editor.text);
						users.set(userNr, user);						
						server.setRemote(userNr, user, 0); // --> Client's onRemote on will be called with remoteId 0				
					default: trace("unknow remote ID");
				}
				
			},
			
			onUserDisconnect: function(server:PeoteServer, userNr:Int, reason:Int)
			{
				trace('onUserDisconnect: jointNr:${server.jointNr}, userNr:$userNr');
				users.remove(userNr);
			},
			
			onError: function(server:PeoteServer, userNr:Int, reason:Int)
			{
				trace('onCreateJointError:$reason, userNr:$userNr');
			}
			
		});
				
		// create server
		peoteServer.create(host, port, channelName);		
	}	
	
	function onInsertText(fromLine:Int, fromPos:Int, chars:String) {
		//trace("INSERT", fromLine, fromPos, chars );
		for (user in users) user.remoteClient.insert(fromLine, fromPos, chars);
	}
	function onDeleteText(fromLine:Int, toLine:Int, fromPos:Int, toPos:Int) {
		//trace("DELETE", fromLine, toLine, fromPos, toPos );
		for (user in users) user.remoteClient.delete(fromLine, toLine, fromPos, toPos);
	}
	
}

class User implements Remote {
	
	public var server:Server;
	public var userNr:Int;
	
	public var remoteClient = (null : ClientRemoteServer);
		
	// ------------------------------------------------------------
	// ---------------------- CONSTRUCTOR -------------------------
	// ------------------------------------------------------------
	
	public function new( server:Server, userNr:Int, remoteClient) {
		this.server = server;
		this.userNr = userNr;
		this.remoteClient = remoteClient;
		
		// TODO: send at first the text
		//remoteClient.hello();
	}
	
	
	// ------------------------------------------------------------
	// ----- Functions that run on Server and called by Client ----
	// ------------------------------------------------------------
	
	@:remote public function hello():Void {
		trace('Hello from client $userNr');		
	}

	//@:remote public function message(msg:String):Void {
		//trace('Message from client $userNr: $msg');
	//}

}
