package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

import ui.UI;

#if html5
import js.Boot;
import js.Browser;
#end

import server.Server;
import Client;


class Main extends Application
{
	var host:String = "localhost";
	var port:Int = 7680;
	var channelName:String = "multiplayer";
	
	var ui:UI;
	
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES: ui = new UI(window, startSample);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// ------------- Create Server &! Client ----------------------
	// ------------------------------------------------------------	
		
	public function startSample()
	{	
		// resolving the channelname! 		
		#if html5
		//catching URL param
		var urlparamRegExp = ~/\?([\w_-]+)$/;
		if (urlparamRegExp.match(Browser.document.URL)) {
			trace("channel:"+urlparamRegExp.matched(1));
		}
		#else //create peote-ui INPUT-field for!
		#end
		
		// try to connect to that channel-name and if it not exists: START OWN SERVER !!! 
		
		// TODO: 
		
		trace("trying to create server ...");
		new Server( ui, host, port, channelName
			#if testlocal
				,true // emulate network (to test locally without peote-server)
			#end
		);
	
		
		trace("trying to enter server ...");
		new Client(ui, host, port, channelName);
		
		
	}
	
	
}
