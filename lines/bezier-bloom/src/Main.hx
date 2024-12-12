package;

import haxe.Timer;
import hxmath.math.Vector2;
import haxe.CallStack;
import lime.app.Application;
import peote.view.*;

class Main extends Application {
	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try {
					// set up the main display
					var peoteView = new PeoteView(window);
					var display = new Display(0, 0, window.width, window.height);
					peoteView.addDisplay(display);

					// framebuffer display for the elements
					var elements_display = new FramebufferDisplay(peoteView, window.width, window.height);
					init_elements(elements_display);

					// render the framebuffer program to the main display
					elements_display.render_to(display);

					// add bloom filter to the framebuffer program
					var blur_kernel_size = 50;
					init_bloom_shader(elements_display, blur_kernel_size);

					// for fun let's rotate the framebuffer on key press
					var angle = 0;
					window.onKeyDown.add((code, modifier) -> switch code {
						case RIGHT: {
								angle += 1;
								angle = angle % 360;
								elements_display.rotate(angle);
							}
						case LEFT: {
								angle -= 1;
								angle = (angle % 360 + 360) % 360;
								elements_display.rotate(angle);
							}
						case _: return;
					});
				} catch (_) {
					trace(CallStack.toString(CallStack.exceptionStack()), _);
				}
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	function init_elements(display:Display) {
		// for storing some elements (so they can be followed)
		var curves_to_follow:Array<Array<PixelElement>> = [];

		// init the buffer/program for the elements
		var buffer = new Buffer<PixelElement>(1024, 1024);
		display.addProgram(new Program(buffer));

		// number of line segments in each curve
		var segments = 60;

		// set up the blue curve
		///////////////////////
		var start = new Vector2(450, -300);
		var start_control = new Vector2(187.5, 825);
		var end_control = new Vector2(1350, 75);
		var end = new Vector2(-150, 450);
		var color = 0x5555f0f0;
		var thickness = 4;
		var curve = make_lines(buffer, start, start_control, end_control, end, segments, color, thickness);
		curves_to_follow.push(curve);

		// set up the red curves
		///////////////////////
		var start = new Vector2(-100, 0);
		var start_control = new Vector2(100, 100);
		var end_control = new Vector2(500, 400);
		var end = new Vector2(800, -100);
		var color = 0xff5555f0;
		var thickness = 1;
		var red_curve_count = 100;
		for (i in 0...red_curve_count) {
			var curve = make_lines(buffer, start, start_control, end_control, end, segments, color, thickness);

			// add every 10th curve to the collection for following
			if (i % 10 == 0) {
				curves_to_follow.push(curve);
			}

			start.y += 40;
			end.x += 1;
		}

		// add elements to follow some of the curves
		////////////////////////////////////////////////
		var size = segments;
		var followers = [
			for (curve in curves_to_follow) {
				var start = curve[0];
				var follower = new PixelElement(start.x, start.y, size, size);
				follower.color = 0xf0f0f080;
				follower.pivot_x = 0.5;
				follower.pivot_y = 0.5;
				{
					follower: buffer.addElement(follower),
					curve: curve
				}
			}
		];

		/// timer to animate the followers
		/////////////////////////////////
		var ms_total = 5000;
		var segment_time = Std.int(ms_total / curve.length);
		var segment_reduction = Std.int(size / curve.length);
		var index = 0;

		var timer = new Timer(segment_time);
		timer.run = () -> {
			for (n => item in followers) {
				// set follower element position to the point in the curve
				var line = item.curve[index];
				item.follower.x = line.x;
				item.follower.y = line.y;

				// use the angle of the line in the curve to determine the angle of the follower
				item.follower.angle = line.angle;

				if (n == 0) {
					// it is the first follower (on the blue line)
					// add 45 degrees to the angle make the element line be across the diagonal
					item.follower.angle += 45;
				} else {
					// it is the other elements (on the red lines)
					// reduce size of the element as it progresses along the line
					if (index == 0) {
						item.follower.width = size;
						item.follower.height = size;
					} else {
						item.follower.width -= segment_reduction;
						item.follower.height = item.follower.width;
					}
				}
			}

			// be sure to update the buffer so the changes are displayed
			buffer.update();

			// increment the index along the curve, wrapping when it reaches the end
			index = (index + 1) % (curve.length - 1);
		}
	}

	function make_lines(buffer:Buffer<PixelElement>, start:Vector2, start_control:Vector2, end_control:Vector2, end:Vector2, samples:Int, color:Color,
			thickness:Int):Array<PixelElement> {
		var elements:Array<PixelElement> = [];

		var point_a = start;
		var point_b = new Vector2(start.x, start.y);
		var segment = 1 / samples;
		var t = 0.0;
		while (t <= 1.0) {
			var tt = t * t;
			var ttt = tt * t;
			var u = 1.0 - t;
			var uu = u * u;
			var uuu = uu * u;
			t += segment;
			point_b = (uuu * start) + (3 * uu * t * start_control) + (3 * u * tt * end_control) + (ttt * end);

			var x = point_a.x;
			var y = point_a.y;
			var x_2 = point_b.x;
			var y_2 = point_b.y;

			var element = new PixelElement(Std.int(x), Std.int(y));
			element.color = color;
			element.to_line(x, y, x_2, y_2, thickness);
			elements.push(buffer.addElement(element));

			point_a = point_b;
		}

		return elements;
	}

	function init_bloom_shader(framebuffer:FramebufferDisplay, size:Int) {
		framebuffer.inject_glsl_program('
		
		// the blurring glsl code is from previous gaussian blur - https://github.com/maitag/peote-playground/tree/master/shaders/blur
		// the blur and the original texture samples are combined to make the bloom effect
		
		float normpdf(in float x, in float sigma) { return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma; }
		
		vec4 blur( int textureID )
		{
			const int mSize = $size;
			
			const int kSize = (mSize-1)/2;
			float kernel[mSize];
			float sigma = 7.0;
			
			float Z = 0.0;
			
			for (int j = 0; j <= kSize; ++j) kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
			for (int j = 0; j <  mSize; ++j) Z += kernel[j];
			
			vec3 final_colour = vec3(0.0);
			
			// fix if kernel-offset is over the border
			vec2 texRes = getTextureResolution(textureID);
			vec2 texResSize = texRes + vec2(float(kSize+kSize),float(kSize+kSize));
			
			for (int i = 0; i <= kSize+kSize; ++i)
			{
				for (int j = 0; j <= kSize+kSize; ++j)
				{
					final_colour += kernel[j] * kernel[i] *
						getTextureColor( textureID, (vTexCoord*texRes + vec2(float(i),float(j))) / texResSize ).rgb;
				}
			}
			
			return vec4(final_colour / (Z * Z), 1.0);
		}

		vec4 bloom( int textureID )
		{
			// sample the texture
			vec4 texColor = getTextureColor(textureID, vTexCoord );

			// get blurred sample
			vec4 bloomColor = blur(textureID);

			float brightness = dot(bloomColor.rgb, vec3(0.2126, 0.7152, 0.0722));

			// check whether fragment output is higher than threshold, if so add the bloom
			const float threshold = 0.01;
			if(brightness > threshold)
			{
				texColor  += bloomColor;
			}

			return texColor;
		}
		', 'bloom(default_ID)');
	}

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------
	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// override function onMouseMove (x:Float, y:Float):Void {}
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}
	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	// ----------------- KEYBOARD EVENTS ---------------------------
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}
	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
}
