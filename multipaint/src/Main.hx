package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;


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

	var channelName:String = "multipaint";
	
	
	public function startSample(window:Window)
	{

		#if (server || (!client))
		
			trace('Server try to create channel "$channelName" at host:$host and port:$port');
			var server = new Server( host, port, channelName
				#if ((!server) && (!client))
					,true // emulate network (to test locally without peote-server)
				#end
			);

		#end
		
		
		
		#if (client || (!server))
			
			trace('Client try to enter servers channel "$channelName" at host:$host and port:$port');
			var client = new Client(window, host, port, channelName);
		
		#end
		
	}
	
	
}
