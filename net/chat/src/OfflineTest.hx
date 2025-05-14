package;

import peote.view.PeoteView;

import view.ui.Ui;
import view.ClientView;
import view.ServerView;

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
		var peoteView = new PeoteView(window);

		// -------- create one gui server in emulation mode -----
		serverView = new ServerView(peoteView, 4, getServerYPos(window.height)+4, window.width-8, getServerHeight(window.height)-8, true);

		// -------- create 2 gui clients in emulation mode ------
		clientViewLeft  = new ClientView(peoteView,                     4, 0,  (window.width>>1) - 6, getServerYPos(window.height));
		clientViewRight = new ClientView(peoteView, (window.width>>1) + 2, 0,  (window.width>>1) - 6, getServerYPos(window.height));

		Ui.registerEvents(window);
	}

	function getServerYPos(h:Int):Int return h-Std.int(h * 0.28);
	function getServerHeight(h:Int):Int return Std.int(h * 0.28);

	override function onWindowResize(w:Int, h:Int) 
	{
		serverView.resize( 4, getServerYPos(h)+4, w-8, getServerHeight(h)-8 );

		clientViewLeft.resize (       4, 0, (w>>1)-6, getServerYPos(h) ); 
		clientViewRight.resize((w>>1)+2, 0, (w>>1)-6, getServerYPos(h) ); 
	}
	
}
