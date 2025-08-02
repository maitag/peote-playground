package;

import lime.ui.MouseButton;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;

class MainScene extends Application {
	var display: Display;
	var buffer: Buffer<PhysicsElem>;

	var world: arcade.World;
	var colorI = 0;
	var colors = [0xb13e53ff, 0xef7d57ff, 0xffcd75ff, 0xa7f070ff, 0x3b5dc9ff, 0x5d275dff];

	override function onWindowCreate() {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try init(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw "Sorry, only works with OpenGL";
		}
	}

	public function init(window: Window) {
		final view = new PeoteView(window);
		display = new Display(0, 0, window.width, window.height, 0x1a1c2cff);
		view.addDisplay(display);

		buffer = new Buffer<PhysicsElem>(4, 4, true);

		final program = new Program(buffer);
		display.addProgram(program);

		initPhysics();
	}

	public function initPhysics() {
		world = new arcade.World(0, 0, window.width, window.height);
		world.gravityY = 300;
	}

	override function update(delta: Int) {
		super.update(delta);
		world.elapsed = delta / 1000;

		for (i in 0...buffer.length) {
			var element: PhysicsElem = buffer.getElement(i);
			element.body.preUpdate(world, element.body.x, element.body.y, element.body.width, element.body.height, element.body.rotation);
		}

		for (i in 0...buffer.length) {
			for (j in i + 1...buffer.length) {
				var element: PhysicsElem = buffer.getElement(i);
				var elementNext: PhysicsElem = buffer.getElement(j);
				world.collide(element.body, elementNext.body);
			}
		}

		for (i in 0...buffer.length) {
			var element: PhysicsElem = buffer.getElement(i);
			element.body.postUpdate(world);
		}

		for (i in 0...buffer.length) {
			var element: PhysicsElem = buffer.getElement(i);
			element.updatePhysics();
			buffer.updateElement(element);
		}
	}

	override function onMouseDown(x: Float, y: Float, button: MouseButton) {
		var element = new PhysicsElem();
		element.setColor(colors[colorI]);
		colorI = (colorI + 1) % colors.length;
		element.body.x = x - (element.w / 2);
		element.body.y = y - (element.h / 2);
		element.body.mass = 1.0;
		buffer.addElement(element);
	}

	override function onWindowResize(width: Int, height: Int) {
		display.width = width;
		display.height = height;
	}
}
