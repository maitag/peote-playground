package;

import echo.World;
import echo.Body;
import echo.data.Options.BodyOptions;

import peote.view.Color;
import peote.view.Program;
import peote.view.Buffer;

@:forward
abstract RectProgram(Program) to Program {
	static var buffer:Buffer<Rect>;
	
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

	public function createElement(world:World, x:Float, y:Float, width:Float, height:Float, color:Color, ?onMove:Body->Float->Float->Void, ?onRotate:Body->Float->Void, ?options:BodyOptions):Rect {

		if (options == null) options = {};
		
		options.x = x;
		options.y = y;
		options.shape = {
			type: RECT,
			width: width,
			height: height
		};

		var body = world.make(options);
		var e:Rect = new Rect( body, width, height, color);

		if (body.mass != 0) {
			body.on_move = (x:Float, y:Float) ->(onMove == null) ? {e.x = x;e.y = y;} : {onMove(body, x, y); e.x = x;e.y = y;};
			body.on_rotate = (r:Float) -> (onRotate == null) ? {e.r = r;} : {onRotate(body, r); e.r = r;};
		}
		
		addElement(e);
		return e;
	}

	public function addElement(e:Rect) buffer.addElement(e);
	public function removeElement(e:Rect) buffer.removeElement(e);
	public function updateElement(e:Rect) buffer.updateElement(e);
	public function update() buffer.update();

	// public inline function addToDisplay(display:Display, ?atProgram:Program, addBefore:Bool=false) this.addToDisplay(display, atProgram, addBefore);
	// public inline function removeFromDisplay(display:Display) this.removeFromDisplay(display);
}