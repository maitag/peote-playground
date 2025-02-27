package;

import echo.World;
import echo.Body;
import echo.data.Options.BodyOptions;

import peote.view.Color;
import peote.view.Program;
import peote.view.Buffer;

@:forward
abstract CircleProgram(Program) to Program {
	static var buffer:Buffer<Circle>;
	
	public function new()
	{
		buffer = new Buffer<Circle>(1024, 1024, true);
		this = new Program(buffer);
		
		this.injectIntoFragmentShader('
		float circle(float radius)
		{
			float x = (vTexCoord.x - 0.5) * 2.0;
			float y = (vTexCoord.y - 0.5) * 2.0;
			float r = sqrt(x * x + y * y);
			float c;
			
			// if ( r <= 1.0) c = 1.0; else c = 0.0;

			// can be made more simple by using "step": https://thebookofshaders.com/glossary/?search=step
			// c = step( r, 1.0);

			// now "antialiasing" the outer range manual: https://thebookofshaders.com/glossary/?search=smoothstep
			// if ( r < 0.5) c = 1.0; else c = smoothstep( 1.0, 0.0, (r-0.5)*2.0 );
			// if ( r < 0.8) c = 1.0; else c = smoothstep( 1.0, 0.0, (r-0.8)*5.0 );

			// or let calculate the falloff in depent of radius (e.g. 2 pixels)
			float aaBorderSize = 2.0;
			float falloffAt = (radius - aaBorderSize/2.0 ) / radius;
			if ( r < falloffAt) c = 1.0; else c = smoothstep( 1.0, 0.0, (r-falloffAt)/(1.0-falloffAt) );

			return c;
		}');
		

		this.setColorFormula( "color * circle(radius)" );
		this.discardAtAlpha(0.0);
		// program.zIndexEnabled= true;
		this.blendEnabled = true;		
	}

	public function createElement(world:World, x:Float, y:Float, radius:Float, color:Color, ?onMove:Body->Float->Float->Void, ?onRotate:Body->Float->Void, ?options:BodyOptions):Circle {

		if (options == null) options = {};
		
		options.x = x;
		options.y = y;
		options.shape = {
			type: CIRCLE,
			radius: radius,
		};

		var body = world.make(options);
		var e:Circle = new Circle( body, radius, color);

		if (body.mass != 0) {
			body.on_move = (x:Float, y:Float) ->(onMove == null) ? {e.x = x;e.y = y;} : {onMove(body, x, y); e.x = x;e.y = y;};
			body.on_rotate = (r:Float) -> (onRotate == null) ? {e.r = r;} : {onRotate(body, r); e.r = r;};
		}
		
		addElement(e);
		return e;
	}

	public function addElement(e:Circle) buffer.addElement(e);
	public function removeElement(e:Circle) buffer.removeElement(e);
	public function updateElement(e:Circle) buffer.updateElement(e);
	public function update() buffer.update();

	// public inline function addToDisplay(display:Display, ?atProgram:Program, addBefore:Bool=false) this.addToDisplay(display, atProgram, addBefore);
	// public inline function removeFromDisplay(display:Display) this.removeFromDisplay(display);
}