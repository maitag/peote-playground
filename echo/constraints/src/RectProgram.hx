package;

import peote.view.Program;
import peote.view.Buffer;

@:forward
abstract RectProgram(Program) to Program {
	static var buffer:Buffer<Circle>;
	
	public function new()
	{

		buffer = new Buffer<Rect>(1024, 1024, true);
		this = new Program(buffer);
		
		//setTexture(..., false);
		/*
		program.injectIntoFragmentShader(

		);
		*/

		// setColorFormula( "" );
		
		// program.zIndexEnabled= true;
		// blendEnabled = true;
		
	}

	public function addElement(circle:Rect) buffer.addElement(circle);
	public function removeElement(circle:Rect) buffer.removeElement(circle);
	public function updateElement(circle:Rect) buffer.updateElement(circle);
	public function update() buffer.update();

	// public inline function addToDisplay(display:Display, ?atProgram:Program, addBefore:Bool=false) this.addToDisplay(display, atProgram, addBefore);
	// public inline function removeFromDisplay(display:Display) this.removeFromDisplay(display);
}