package;

using tink.CoreApi;
#if macro
using tink.MacroApi;
#end

import tink.cli.*;
import tink.Cli;


class DedicatedServer
{
	
	static function main()
	{
		var peoteNetTest = new MultiPaintServer();
		
		Cli.process(Sys.args(), peoteNetTest).handle(
			function(result:Outcome<Noise, Error>) {
				switch result
				{
					case Success(_): //Sys.exit(0);
					case Failure(e):
						var message = "\nError while parsing commandline parameters: " + e.message;
						if(e.data != null) message += ', ${e.data}';
						Sys.println(message);
						peoteNetTest.doc(); 
						Sys.exit(e.code);
				}
			}
		);
	}
	
}

@:alias(false)
class MultiPaintServer {
	// ---------------- Commandline Parameters
	/**
		host/ip of the running peote-server
		*
	**/
	@:flag('--host', '-o') @:alias(false)
	public var host:String = "localhost";
	
	/**
		port of running peote-server
		*
	**/
	@:flag('--port', '-p') @:alias(false)
	public var port:Int = 7680;
	
	/**
		name of the channel to create (default is "testserver")		
		*
	**/
	@:flag('--channelName', '-n') @:alias(false)
	public var channelName:String = "multipaint";
	
	/**
		 prints out more informations for logging 
		*
	**/
	@:flag('--verbose', '-v') @:alias(false)
	public var verbose:Bool = false;
	
	/**
		print this help
	**/
	@:flag('--help','-h') @:alias(false)
	public var help:Bool = false;
	// --------------------------------------
	
	public function new() {}

	/**
		Dedicated Server for multipaint sample.

		Before get starting you need to run a peote-server. 
		(https://github.com/maitag/peote-server)
	**/
	@:defaultCommand
	public function start(rest:Rest<String>) {
		if (help) doc();
		else {
			Sys.println('channelName: $channelName');
			//Sys.println('rest: $rest');
			
			var server = new Server( host, port, channelName);// , log );

		}
	}
	
	public function log(s:String, type:Int, nr:Int):Void {
		Sys.println('$s');
		// TODO: using good lib for colored output here
	}
	
	public function doc():Void {
		Sys.println(Cli.getDoc(this));
	}

}
