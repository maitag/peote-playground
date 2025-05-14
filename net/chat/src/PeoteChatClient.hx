package;

import peote.view.PeoteView;

import view.ui.Ui;
import view.ClientView;

class PeoteChatClient extends lime.app.Application
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
		var peoteView = new PeoteView(window);

		// ------- create gui client -------
		clientView = new ClientView(peoteView, 0, 0, window.width, window.height);
		
		Ui.registerEvents(window);
	}	

	override function onWindowResize(w:Int, h:Int) 
	{
		clientView.resize ( 0, 0, w, h ); 
	}

}
