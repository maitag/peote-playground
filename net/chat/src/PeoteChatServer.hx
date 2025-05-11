package;

import peote.view.PeoteView;

import view.ui.Ui;
import view.ServerView;


class PeoteChatServer extends lime.app.Application
{
	var serverView:ServerView;
	
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
		trace("onUiInit");

		var peoteView = new PeoteView(window);

		// -------- create gui server -----
		serverView = new ServerView(peoteView, 0, 300, 800, 300, true);

	}	


	// TODO: resize handler !
	
}
