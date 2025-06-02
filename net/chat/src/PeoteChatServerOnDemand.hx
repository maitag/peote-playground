package;

import peote.view.PeoteView;

import net.Server;

import view.ui.Ui;
import view.ClientView;

class PeoteChatServerOnDemand extends lime.app.Application
{
	var clientView:ClientView;
	
	override function onWindowCreate():Void
	{
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try Ui.init(onUIInit)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	public function onUIInit() 
	{
		#if html5
		// resolving the channelname by catching the URL param
		var urlparamRegExp = ~/\?([\w_-]+)$/;
		if (urlparamRegExp.match(js.Browser.document.URL)) {
			Config.defaultChannel = urlparamRegExp.matched(1);
		}
		#end

		var peoteView = new PeoteView(window);

		// ------- try to create a server into background --------
		startBackgroundServer();

		// ------- create gui client -------
		clientView = new ClientView(peoteView, 0, 0, window.width, window.height, startBackgroundServer);
		
		Ui.registerEvents(window);

		window.onResize.add(resize);
	}	

	function startBackgroundServer() {
		new Server(Config.host, Config.port, Config.channel, (s:String,?clear:Bool) -> trace(s) );
	}

	function resize(w:Int, h:Int) 
	{
		clientView.resize ( 0, 0, w, h ); 
	}

}
