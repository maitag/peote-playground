package;

import peote.net.Reason;
import ui.UI;
import peote.net.PeoteClient;
import peote.net.Remote;

import Server.User; // needs for RemoteGeneration

class Client implements Remote {
	
	public var remoteUser = (null : UserRemoteClient);
	
	var ui:UI;
	var peoteClient:PeoteClient;
	
	public function new(ui:UI, host:String, port:Int, channelName:String, ?onMissingServer:Void->Void) 
	{
		this.ui = ui;
		
		peoteClient = new PeoteClient(
		{
			onEnter: function(client:PeoteClient)
			{
				trace('onEnterJoint: Joint number ${client.jointNr} entered');
				ui.createCodeEditor();
				client.setRemote(this, 0);  // --> Server's onRemote will be called with remoteId 0
			},
			
			onRemote: function(client:PeoteClient, remoteId:Int)
			{
				trace('Client onRemote: jointNr:${client.jointNr}, remoteId:$remoteId');
				switch (remoteId) {
					case 0:	remoteUser = User.getRemoteClient( client, remoteId);
							remoteUser.hello();
					default: trace("unknow remote ID");
				}
			},
			
			onDisconnect: function(client:PeoteClient, reason:Int)
			{
				trace('onDisconnect: jointNr=${client.jointNr}');
			},
			
			onError: function(client:PeoteClient, reason:Int)
			{
				if (onMissingServer != null && reason == Reason.ID) onMissingServer();
				else trace('onEnterJointError:$reason');
			}
			
		});		
		
		// enter server
		peoteClient.enter(host, port, channelName);
	}
	
	
	// ------------------------------------------------------------
	// ----- Functions that run on Client and called by Server ----
	// ------------------------------------------------------------
	
	@:remote public function hello():Void {
		trace('Hello from server');		
	}

	@:remote public function insert(fromLine:Int, fromPos:Int, chars:String):Void {
		ui.insertCode(fromLine, fromPos, chars);
	}

	@:remote public function delete(fromLine:Int, toLine:Int, fromPos:Int, toPos:Int):Void {
		ui.deleteCode(fromLine, toLine, fromPos, toPos);
	}

}


