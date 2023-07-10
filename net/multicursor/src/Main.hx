package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

import server.Server;
import Client;


class Main extends Application
{
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// ------------- Create Server &! Client ----------------------
	// ------------------------------------------------------------	
	var host:String = "localhost";
	var port:Int = 7680;

	var channelName:String = "multiplayer";
	
	public function startSample(window:Window)
	{		
		// TODO: 
		
		// at FIRST -> resolving the channelname! 
		
		// #if HTML: catching URL param
		// #else:    create peote-ui INPUT-field for!
		
		// try to connect to that channel-name and if it not exists: START OWN SERVER !!! 
		
		
		
		
		// TODO: replacing all build-conditions here by only #testlocal !!!
		
		#if (server || (!client))
		
			trace("trying to create server ...");
			new Server( host, port, channelName
				#if ((!server) && (!client))
					,true // emulate network (to test locally without peote-server)
				#end
			);

		#end
		
		
		
		#if (client || (!server))
			
			trace("trying to enter server ...");
			new Client(window, host, port, channelName);
		
		#end
		
	}
	
	
}
