package;

import utils.Loader;
import peote.view.*;
import echo.Line;
import echo.Body;
import echo.Echo;
import echo.World;
import echo.math.Vector2;
import lime.graphics.Image;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseWheelMode;
import lime.app.Application;
import haxe.CallStack;

using echo.util.ext.FloatExt;

class Main extends Application {
	var world:World;
	var bodies:Array<Body> = [];

	var ray_buffer:Buffer<Ray>;
	var circle_buffer:Buffer<Shape>;
	var rectangle_buffer:Buffer<Shape>;

	var ray_count_maximum:Int;
	var ray_thickness:Int;
	var ray_count:Int;

	var mouse:Vector2;
	var buffer:Buffer<Lighting>;
	var view:Lighting;
	var ray_length:Int;
	var is_draw_rays:Bool = true;

	var is_ready:Bool = false;
	var lighting_buffer:Buffer<Lighting>;

	override function onWindowCreate() {
		switch window.context.type {
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample()
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			case _:
				throw("Sorry, only works with OpenGL.");
		}
	}

	function startSample() {

		mouse = new Vector2(0, 0);
		var widthWindow = window.width;
		var heightWindow = window.height;
		
		var peoteView = new PeoteView(window);

		// for displaying elements behind the light/shadows
		var background_display = new Display(0, 0, widthWindow, heightWindow);
		peoteView.addDisplay(background_display);

		// rays are rendered to texture
		var fbo_rays = {
			display: new Display(0, 0, widthWindow, heightWindow),
			texture: new Texture(widthWindow, heightWindow)
		}
		peoteView.setFramebuffer(fbo_rays.display, fbo_rays.texture);
		peoteView.renderToTexture(fbo_rays.display);
		peoteView.addFramebufferDisplay(fbo_rays.display);
		
		// shapes are rendered to 
		var shapes_display = new Display(0, 0, widthWindow, heightWindow);
		peoteView.addDisplay(shapes_display);
		
		// add the rays display to be visible, but hide it (for debugging only)
		peoteView.addDisplay(fbo_rays.display);
		fbo_rays.display.hide();
		shapes_display.hide(); // also hide shapes for now

		// toggle ray/shape elements visibility on/off with mouse click
		window.onMouseDown.add((x, y, button) -> {
			if(fbo_rays.display.isVisible){
				fbo_rays.display.hide();
				shapes_display.hide();
			}
			else{
				fbo_rays.display.show();
				shapes_display.show();
			}
		});
		
		// set up the world for echo physics
		world = Echo.start({
			width: widthWindow,
			height: heightWindow,
			x: 0,
			y: 0,
		});

		// set up rectangles to block the rays

		var rectangles = [
			{ x: 60, y: 60, w: 30, h: 30, r: 0.0 },
			{ x: 100, y: 200, w: 75, h: 30, r: 12.0 },
			{ x: 200, y: 400,	w: 30, h: 100,	r: -24.0	},
		];

		rectangle_buffer = new Buffer<Shape>(rectangles.length);
		var rectangle_program = new Program(rectangle_buffer);
		shapes_display.addProgram(rectangle_program);
		
		for (rect in rectangles) {
			var body = world.make({
				shape: {
					type: RECT,
					width: rect.w,
					height: rect.h,
				},
				x: rect.x,
				y: rect.y,
				rotational_velocity: rect.r,
			});

			bodies.push(body);

			var element = rectangle_buffer.addElement(new Shape(rect.x, rect.y, rect.w, rect.h, 0xff0000FF));

			body.on_move = (x, y) -> {
				element.x = x;
				element.y = y;
			}

			body.on_rotate = a -> element.angle = a;
		}

		// set up circles to block the rays		

		var circles = [
			{ x: 500, y: 560,	r: 150 },
			{ x: 660, y: 150, r: 90 },
		];

		circle_buffer = new Buffer<Shape>(circles.length);
		var circle_program = new Program(circle_buffer);
		shapes_display.addProgram(circle_program);
		
		circle_program.injectIntoFragmentShader('
		vec4 circle(vec4 color, vec2 pos)
		{
			return vec4(color.rgb, (step(length(pos), 1.0) * color.a));
		}
		');
		circle_program.setColorFormula('circle(tint, vTexCoord * 2.0 - 1.0)');
		
		for (circle in circles) {
			var diameter = circle.r * 2;

			var body = world.make({
				shape: {
					type: CIRCLE,
					radius: circle.r
				},
				x: circle.x,
				y: circle.y
			});

			bodies.push(body);
			var element = circle_buffer.addElement(new Shape(circle.x, circle.y, diameter, diameter, 0xff0000FF));

			body.on_move = (x, y) -> {
				element.x = x;
				element.y = y;
			}
		}

		// set up the rays, total rays visible is controlled by mouse wheel, thickesn decrease/increase with keyboard j/k
		
		ray_count = 360;
		ray_length = Std.int(widthWindow * 1.5);
		ray_count_maximum = ray_count * 4;
		ray_thickness = 12;

		ray_buffer = new Buffer<Ray>(ray_count_maximum * 2);
		var ray_program = new Program(ray_buffer);
		fbo_rays.display.addProgram(ray_program);


		// this will display the 'darkness' (shadow) with rays lightening some areas
		var display = new Display(0, 0, widthWindow, heightWindow);
		peoteView.addDisplay(display);
		lighting_buffer = new Buffer<Lighting>(1);
		var program = new Program(lighting_buffer);
		program.blendEnabled = true;
		program.injectIntoFragmentShader('
		vec4 compose(vec4 darkness, int rays_id, float ray_origin_x, float ray_origin_y)
		{
			vec4 ray = getTextureColor( rays_id, vTexCoord);
			vec2 ray_origin = vec2(ray_origin_x, ray_origin_y) / vSize;
			
			if(ray.a > 0.0)
			{ 
				darkness.a = 1.0 - mix(1.0, 0.0, pow(distance(vTexCoord, ray_origin), 0.42));
			}
			
			return darkness;
		}
		');

		program.setTexture(fbo_rays.texture, "rays");

		program.setColorFormula('compose(darkness, rays_ID, ray_origin_x, ray_origin_y)');

		display.addProgram(program);
		view = lighting_buffer.addElement(new Lighting(0, 0, widthWindow, heightWindow));
		// give the darkness some color and change alpha to not be fully opaque
		view.darkness.bF = 0.02;
		view.darkness.gF = 0.02;
		view.darkness.aF = 0.9;

		// load background image and let update is_ready!
		Loader.image("assets/test0.png", (image:Image) -> {
			var buffer_ = new Buffer<Shape>(1);
			var program_ = new Program(buffer_);
			program_.setTexture(Texture.fromData(image), "background");
			background_display.addProgram(program_);
			var bg = new Shape(0, 0, widthWindow, heightWindow, 0xffffffFF);
			bg.pivot_x = 0.0;
			bg.pivot_y = 0.0;

			buffer_.addElement(bg);
			is_ready = true;
		});
	}

	// for tracking mouse position
	override function onMouseMove(x:Float, y:Float) {
		mouse.x = x;
		mouse.y = y;
	}

	// for changing total rays
	override function onMouseWheel(deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode) {
		var change = deltaY > 0 ? 1 : -1;
		var next_ray_count = ray_count + change * 10;
		if (next_ray_count > 3 && next_ray_count < ray_count_maximum) {
			ray_count = next_ray_count;
		}
	}

	// for changing size of rays
	override function onKeyDown(keyCode:KeyCode, modifier:KeyModifier) {
		var change = switch keyCode {
			case J: -1;
			case K: 1;
			case _: 0;
		}
		var next_thickness = ray_thickness + change;
		if (next_thickness > 1) {
			ray_thickness = next_thickness;
		}
	}

	override function update(deltaTime:Int) {
		if (!is_ready)
			return;

		// step physics simulation
		world.step(deltaTime / 1000);
		view.ray_origin_x = mouse.x;
		view.ray_origin_y = mouse.y;

		// clear old rays (fres ones added below)
		ray_buffer.clear();

		var line = Line.get();

		for (n in 0...ray_count) {
			line.set_from_vector(mouse, 360 * (n / ray_count), ray_length);
			var intersection = line.linecast(bodies, world);
			// if there is intersection then the ray hit an obstacle (ray will be shorter)
			if (intersection != null && intersection.closest != null) {
				var data = intersection.closest;
				ray_buffer.addElement(new Ray(data.line.start.x, data.line.start.y, data.hit.x, data.hit.y, ray_thickness, 0xffffffFF));
			} 
			// else ray can be full length
			else {
				ray_buffer.addElement(new Ray(line.start.x, line.start.y, line.end.x, line.end.y, ray_thickness, 0xffffffFF));
			}
		}

		line.put();

		// update the element buffers
		rectangle_buffer.update();
		lighting_buffer.update();
		circle_buffer.update();
	}
}
