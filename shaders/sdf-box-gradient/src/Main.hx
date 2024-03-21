package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.view.*;

class Main extends Application {
	var canvas:Canvas;
	var buffer:Buffer<Canvas>;
	var display:Display;
	var is_ready:Bool = false;

	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------

	public function startSample(window:Window) {
		var peoteView = new PeoteView(window);

		buffer = new Buffer<Canvas>(1, 1, true);
		display = new Display(0, 0, window.width, window.height);
		var program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);

		canvas = new Canvas(0, 0, window.width, window.height);
		buffer.addElement(canvas);

		var frag_shader_code = '
		
		// signed distance field for a rectangle
		float sdfBox(in vec2 position, in vec2 size)
		{
			vec2 distance = abs(position) - size;
			return length(max(distance, 0.0)) + min(max(distance.x, distance.y), 0.0);
		}

		// fun color gradient/gradient function
		// gradient can be desigenre here - http://dev.thi.ng/gradients/
		vec3 gradient(float t, vec3 a, vec3 b, vec3 c, vec3 d)
		{
			return a + b * cos(6.28318 * (c * t + d));
		}

		// the function called by program.SetColorFormula
		
		vec4 compose(vec2 mouse)
		{
			// vTexCoord is on range 0 to 1
			// uv change range -1.0 to 1.0 (moves center to 0.0)
			vec2 uv = vTexCoord * 2.0 - 1.0;
			
			// fix aspect ratio to be square of height
			uv.x *= vSize.x / vSize.y;
			
			// time value based on uTime but slowed down
			float time = uTime * 0.42;
			
			// make mouse.xy range 0 to 1
			mouse = mouse / vSize;
			
			// cos sin and time used to distort the sdf and keep things moving
			// mouse makes movement a little bit interactive
			vec2 co = cos((uv / 8.0) / 7.0 + time) * mouse.x;
			vec2 si = sin((uv * 8.0) / 7.0 + time);
			
			// get the (signed) distance (field)
			float distance = sdfBox(co, si);
			
			// start with black color
			vec3 fragColor = vec3(0.0);
			
			// change color by gradient, distance and time
			fragColor += gradient(distance + time,
				vec3(0.051, 0.572, 0.558),
				vec3(0.525, 0.320, 0.418),
				vec3(0.402, 0.575, 1.111),
				vec3(4.641, 5.708, 0.301));
		
			// increase the amount of distance fields
			float fields = 18.0;
			distance = sin(distance * fields) / fields;
		
			// pow to improve constrast
			distance = pow(0.01 / distance, 1.2);
		
			// apply distance fields to color 
			fragColor *= distance;
		
			return vec4(fragColor, 1.0);
		}
		';

		// inject the shader into the program (including time)
		var uTimeUniformEnabled = true;
		program.injectIntoFragmentShader(frag_shader_code, uTimeUniformEnabled);

		// set shader for coloring the program, note that we pass in mouse variables from Canvas Element
		program.setColorFormula('compose(vec2(fMouseX, fMouseY))');

		// start time
		peoteView.start();

		// we are ready! ^_^
		is_ready = true;
	}

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------

	override function onMouseMove(x:Float, y:Float):Void {
		// update mouse positons on Canvas Element
		canvas.mouseX = x;
		canvas.mouseY = y;

		// the element changed so update in the buffer
		buffer.updateElement(canvas);
	}

	override function onWindowResize(width:Int, height:Int) {
		// resize display and element to window size
		
		display.width = width;
		display.height = height;
		
		canvas.w = width;
		canvas.h = height;
		
		// the element changed so update in the buffer
		buffer.updateElement(canvas);
	}
}

@:publicFields
// Element to draw shader on
class Canvas implements Element {
	// position in pixel (relative to upper left corner of Display)
	@posX var x:Int;
	@posY var y:Int;

	// size in pixel
	@sizeX @varying var w:Int;
	@sizeY @varying var h:Int;

	// mouse position
	@custom("fMouseX") @varying var mouseX:Float;
	@custom("fMouseY") @varying var mouseY:Float;

	function new(x:Int = 0, y:Int = 0, w:Int, h:Int) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}
}
