package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Element;
import peote.view.Color;

import ui.Ui;

class Main extends Application
{
	var peoteView:PeoteView;
	var ui:Ui;
	
	override function onWindowCreate():Void
	{
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try init(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function init(window:Window)
	{
		peoteView = new PeoteView(window);
		ui = new Ui(peoteView, onUIInit);
		
	}
	
	public function onUIInit() 
	{
		trace("onUiInit");

		

	}	

	
}

