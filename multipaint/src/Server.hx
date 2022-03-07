package;

import peote.net.PeoteServer;
import peote.net.Remote;

import peote.io.Byte;
import peote.io.UInt16;
import peote.io.Int16;
import peote.io.Int32;
import peote.io.Double;


class Server 
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
				
/*				// server object where methods can be called by remote
				var serverFunctions = new ServerFunctions();
				serverFunctions.test = function() {
					out.log('serverobject -> test()');
				};
				serverFunctions.message = function(s:String, b:Bool) {
					out.log('serverobject -> message("$s", $b)');
				};
				serverFunctions.numbers = function(a:Byte, b:UInt16, c:Int16, d:Int32, e:Int, f:Float, g:Double) {
					out.log('serverobject -> numbers($a, $b, $c, $d, $e, $f, $g)');
				};				
				serverFunctions.complex = function(b:Bytes, a:Vector<Array<Int>>) {
					out.log('serverobject -> complex($b, $a)');
				};				
				serverFunctions.lists = function(list:List<Int>) {
					out.log('serverobject -> lists($list)');
				};				
				//serverFunctions.maps = function(m:IntMap< StringMap<Array<Int>> >) {
				serverFunctions.maps = function(m:Map< Int, Map<String, Array<Int>> >) {
					out.log('serverobject -> maps(');
					for (k in m.keys()) out.log(""+m.get(k));
				};
				serverFunctions.hxbit = function(u:User) {
					out.log('serverobject -> hxbit(${u.name}, ${u.age})');
				};
				serverFunctions.msgpack = function(o:Dynamic) {
					out.log('serverobject -> msgpack($o)');
				};
				serverFunctions.msgpackTyped = function(m:Message) {
					out.log('serverobject -> msgpackTyped($m)');
				};
				
				server.setRemote(userNr, serverFunctions); // --> Client's onRemote on will be called with 0
*/				
			},
			onRemote: function(server:PeoteServer, userNr:Int, remoteId:Int)
			{
				trace('onRemote: jointNr:${server.jointNr}, userNr:$userNr, remoteId:$remoteId');
				
/*				switch (remoteId) {
					case FirstClientFunctions.remoteId: 
						var clientFunctions = FirstClientFunctions.getRemoteServer(server, userNr, remoteId);
						clientFunctions.message("hello from server"); // call client-function of first object
					case SecondClientFunctions.remoteId:
						var secondClientFunctions = SecondClientFunctions.getRemoteServer(server, userNr, remoteId);
						secondClientFunctions.test(); // call client-function of second object
					default: trace("unknown remoteId");
				}
*/			

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
		
		
		// create a server
		peoteServer.create(host, port, channelName);
		
	}

/*// functions that run on Server
class ServerFunctions implements Remote {
	@:remote public var test:Void->Void;
	@:remote public var message:String->Bool->Void;
	@:remote public var numbers:Byte->UInt16->Int16->Int32->Int->Float->Double->Void;
	@:remote public var complex:Bytes -> Vector<Array<Int>> -> Void;
	@:remote public var lists:List<Int> -> Void;
	//@:remote public var maps:IntMap< haxe.ds.StringMap< Array<Int>> > -> Void;
	@:remote public var maps:Map<Int, Map< String, Array<Int>> > -> Void;
	
	// enable hxbit lib in project.xml to use it's serialization here ( https://lib.haxe.org/p/hxbit/ )
	@:remote public var hxbit: User -> Void;
	
	// enable msgpack lib in project.xml to use it's serialization here( https://lib.haxe.org/p/msgpack-haxe/ )
	@:remote public var msgpackTyped: Message -> Void;
	@:remote public var msgpack: Dynamic -> Void; 
}
*/


}