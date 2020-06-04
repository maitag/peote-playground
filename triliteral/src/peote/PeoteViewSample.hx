package peote;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;


class PeoteViewSample
{
	var peoteView:PeoteView;
	
	public function new(window: lime.ui.Window) {
	
		peoteView = new PeoteView(window.context, window.width, window.height);

		var buffer = new Buffer<Sprite>(4, 4, true);
		var display = new Display(10, 10, window.width - 20, window.height - 20, Color.GREEN);
		var program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);

		// add a Sprite
		var sprite = new Sprite();
		buffer.addElement(sprite);
	
	}
	
	
	// ------------------------------------------------------------
	// ---------------------  EVENTS ------------------------------
	// ------------------------------------------------------------	

	public function render():Void
	{
		peoteView.render(); // rendering all Displays -> Programs - Buffer
	}
	
	public function onWindowResize (width:Int, height:Int):Void
	{
		peoteView.resize(width, height);
	}

}
