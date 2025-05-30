package net;

import haxe.ds.IntMap;
import peote.net.PeoteClient;
import peote.net.Reason;

class Client {
	
	var peoteClient:PeoteClient;
	var clientRemote:ClientRemote;

	var host:String;
	var port:Int;
	var channel:String;
	
	// callbacks:
	var msg:String->?String->Void;
	var log:String->?Bool->Void;
	
	var onRemoteReady:Void->Void;
	var onDisconnect:Reason->Void;
	var onError:Reason->Void;
	
	var onClientEnter:String->?Bool->Void;
	var onClientMessage:String->?Bool->Void;


	var userNick = new IntMap<String>();

	public function new(host:String, port:Int, channel:String, msg:String->?String->Void, log:String->?Bool->Void) 
	{
		this.host = host;
		this.port = port;
		this.channel = channel;

		this.msg = msg;
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

				onDisconnect(reason); // <-- callback to View
			},
			
			onError: function(client:PeoteClient, reason:Reason)
			{
				log('Error:$reason');

				onError(reason); // <-- callback to View
			}			
		});		
	}
	
	public function connect(onRemoteReady:Void->Void, onDisconnect:Reason->Void, onError:Reason->Void)
	{
		this.onRemoteReady = onRemoteReady;
		this.onDisconnect = onDisconnect;
		this.onError = onError;

		// enter server
		log('try to connect to $host:$port\nenter channel "$channel" ...');
		peoteClient.leave(); // <-- if was opened before!
		peoteClient.enter(host, port, channel);
	}


	// --- these functions are called by the ClientView ----

	public function setNickName(nickName:String) {
		clientRemote.server.setNickName(nickName);
	}

	public function send(m:String) {
		clientRemote.server.message(m);
	}


	// --- these functions are called back by ClientRemote ----

	function userList(nickNames:Map<Int,String>):Void {
		var users = "";
		for ( k=>v in nickNames ) {
			userNick.set(k, v);
			users += v + "\n";
		}
		if (users == "") msg("No other user logged in yet.\n");
		else msg(users + "are logged in.\n");
	}

	function userMessage(userNr:Int, message:String):Void
	{
		msg(message, userNick.get(userNr));
	}

	function userEnter(userNr:Int, nick:String):Void
	{
		msg('User "$nick" enters');
		userNick.set(userNr, nick);
	}

	function userLeave(userNr:Int):Void
	{
		msg('User "${userNick.get(userNr)}" leaves');
		userNick.remove(userNr);
	}

	function userSetNickName(userNr:Int, nick:String):Void 
	{
		msg('User "${userNick.get(userNr)}" changes nickname to: "$nick"');
		userNick.set(userNr, nick);
	}

}


