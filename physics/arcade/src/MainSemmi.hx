package;

import peote.view.Color;
import lime.ui.MouseButton;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;

class MainSemmi extends Application {
	var display: Display;
	var buffer: Buffer<PhysicsElem>;

	var world: arcade.World;

	override function onWindowCreate() {
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

		for (i in 0...buffer.length)
		{
			// 1
			var element: PhysicsElem = buffer.getElement(i);
			element.body.preUpdate(world, element.body.x, element.body.y, element.body.width, element.body.height, element.body.rotation);
		
			// 2
			for (j in i + 1...buffer.length) {
				var element: PhysicsElem = buffer.getElement(i);
				var elementNext: PhysicsElem = buffer.getElement(j);
				world.collide(element.body, elementNext.body);
			}
		
			// 3
			var element: PhysicsElem = buffer.getElement(i);
			element.body.postUpdate(world);		

			// 4
			var element: PhysicsElem = buffer.getElement(i);
			element.updatePhysics();
			buffer.updateElement(element);
		}
		
	}

	override function onMouseDown(x: Float, y: Float, button: MouseButton) {
		var element = new PhysicsElem();
		element.setColor(Color.random());
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
