package;

import peote.view.PeoteView;

import view.ui.Ui;
import view.ServerView;
import view.ClientView;

class OfflineTest extends lime.app.Application
{
	var serverView:ServerView;
	var clientViewLeft:ClientView;
	var clientViewRight:ClientView;
	
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

		// -------- create one gui server in emulation mode -----
		serverView = new ServerView(peoteView, 0, 300, 800, 300, true);


		// -------- create 2 gui clients --------
		clientViewLeft = new ClientView(peoteView, 0, 0, 400, 300);
		clientViewRight = new ClientView(peoteView, 400, 0, 400, 300);

	}	


	// TODO: resize handler !
	
}
