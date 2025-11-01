import peote.view.PeoteView;
import haxe.CallStack;
import lime.app.Application;

class MainStage extends Application
{
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample()
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	function startSample()
	{
		var peoteView = new PeoteView(window);
		var display = new Room(0, 0, window.width, window.height);
		display.addToPeoteView(peoteView);
	}
}
