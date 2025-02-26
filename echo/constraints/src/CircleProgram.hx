package;

import peote.view.Program;
import peote.view.Buffer;

@:forward
abstract CircleProgram(Program) to Program {
	static var buffer:Buffer<Circle>;
	
	public function new()
	{

		buffer = new Buffer<Circle>(1024, 1024, true);
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

	public function addElement(circle:Circle) buffer.addElement(circle);
	public function removeElement(circle:Circle) buffer.removeElement(circle);
	public function updateElement(circle:Circle) buffer.updateElement(circle);
	public function update() buffer.update();

	// public inline function addToDisplay(display:Display, ?atProgram:Program, addBefore:Bool=false) this.addToDisplay(display, atProgram, addBefore);
	// public inline function removeFromDisplay(display:Display) this.removeFromDisplay(display);
}