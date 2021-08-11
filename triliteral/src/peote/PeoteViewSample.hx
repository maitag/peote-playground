package peote;

import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;


class PeoteViewSample
{
	public var peoteView:PeoteView;
	
	public function new(window:Window) {
	
		peoteView = new PeoteView(window, false);

		var buffer = new Buffer<Sprite>(4, 4, true);
		var display = new Display(10, 10, window.width - 20, window.height - 20, Color.GREEN);
		var program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);

		// add a Sprite
		var sprite = new Sprite();
		buffer.addElement(sprite);
	
	}
	
}
