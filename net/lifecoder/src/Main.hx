package;

import lime.app.Application;
import ui.UI;

#if html5
//import js.Boot;
import js.Browser;
#end


class Main extends Application
{
	var host:String = "localhost";
	var port:Int = 7680;
	var channelName:String = "life-coder";
	
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
			//trace("channel:" + urlparamRegExp.matched(1));
			channelName = urlparamRegExp.matched(1);
		}
		#end
		
		#if testlocal
		
		new Server( ui, host, port, channelName, true );// emulate network
		new Client(ui, host, port, channelName);
		
		#else
		
		// try to connect to that channel-name and if it not exists: START OWN SERVER !!! 
		
		trace("trying to enter server ...");
		new Client(ui, host, port, channelName, function() {
			// if no server exist
			trace("trying to create server ...");
			new Server( ui, host, port, channelName );
		});
		
		#end
	}
	
	
}
