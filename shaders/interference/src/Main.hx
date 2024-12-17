package;

import haxe.CallStack;
import haxe.Timer;
import lime.app.Application;
import lime.ui.Window;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Element;
import peote.view.PeoteView;
import peote.view.Program;
import peote.view.element.Elem;

using Lambda;

class Main extends Application {
	public function new() {
		super();
	}

	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try {
					startSample(window);
				} catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}


	public function startSample(window:Window) {
		var peoteView = new PeoteView(window);
		
		var buffer:Buffer<Canvas> = new Buffer<Canvas>(1, 1, true);
		var display = new Display(0, 0, window.width, window.height);
		var program = new Program(buffer);
		
		peoteView.addDisplay(display);
		display.addProgram(program);

		
		var canvas = new Canvas(0, 0, window.width, window.height);
		buffer.addElement(canvas);


		program.injectIntoFragmentShader('
			vec4 compose() {
        vec2 uv = vTexCoord;
				uv -= 0.5;
				uv.x *= vSize.x / vSize.y; 
				float t = uTime;
			
			
				vec2 uv1 = uv; 
				uv1.x += sin(t);
				
			
				float upper = 100.0; 
				float lower = 40.0; 
				float midline = (upper + lower) / 2.0;
				float freq = (upper - midline) * sin(t*3.0) + midline; 
				
				
				float wave1 = sin(freq * length(uv1) - t); 

				wave1 = wave1 * 0.5 + 0.5;

				vec2 uv2 = uv; 
				uv2.x -= sin(t);

				float wave2 = sin(freq * length(uv2) - t); 
				wave2 = wave2 * 0.5 + 0.5;
				
				vec2 uv3 = uv; 
				uv3.y += 0.2;

				float wave3 = cos(freq * length(uv3) - t); 
				wave3 = wave3 * 0.5 + 0.5;

				float wave = wave1 *  wave2 * wave3;
				
				float intensity = smoothstep(1.0, 0.0, length(uv));

				float bluesmooth = smoothstep(0.0, 0.3, length(uv));
				float redsmooth = smoothstep(0.0, 0.3, length(uv)-0.3);
				float greensmooth = smoothstep(0.0, 0.3, length(uv)-0.6);
				
				
				
				vec4 color1 = vec4(0.0, 0.0, 0.0, 1.0);
				vec4 color2 = vec4(0.1 + redsmooth  + cos(t), 0.4 + greensmooth,0.4 + bluesmooth , 1.0); 
				
				vec4 color = mix(color1, color2, wave);

				return (color + (color * intensity)); 
			}
		', true);


		
		program.setColorFormula("compose()");
		peoteView.start();

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


	function new(x:Int = 0, y:Int = 0, w:Int, h:Int) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}
}
