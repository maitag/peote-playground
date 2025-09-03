package;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.Image;

import peote.view.*;

class Main extends Application
{
	var speed:UniformFloat;
	var buffer:Buffer<Cypher>;

	override function onWindowCreate():Void
	{
		if (switch (window.context.type) {case WEBGL, OPENGL, OPENGLES: false; default: true;})
			throw("Sorry, only works with OpenGL.");
		
		var peoteView = new PeoteView(window);

		var display = new Display(0, 0, window.width, window.height, Color.GREEN1);
		peoteView.addDisplay(display);

		buffer = new Buffer<Cypher>(1024, 512);

		var program = new Program(buffer);
		display.addProgram(program);

		speed = new UniformFloat("uSpeed", 0.000000000000005);

		Load.image("assets/peote_font.png", true, function(image:Image)
		{
			var texture = new Texture(image.width, image.height);
			texture.setData(image);
			
			texture.tilesX = 16;
			texture.tilesY = 16;
			
			program.addTexture(texture, "custom");
			
			program.injectIntoVertexShader(true, [speed]);
			
			program.setFormula("n", "n + mod(uTime*min(pow(10.0,precision)*uSpeed,1000.0), 10.0)");

			peoteView.start(); // \o/ *hugs all haxe m o n ks °^°;)~
		});
		
		// TEST SPAWNING
		for (i in 0...16) {
			buffer.addElement(new Cypher(i, i*50, 10, 50, 50, Color.random(255) ) );
		}
	}
	
	// ----------------- TIME EVENTS ------------------------------
	override function update(deltaTime:Int):Void {
		speed.value *= 1.003;
	}
	// override function render(context:lime.graphics.RenderContext):Void {}

	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseMove (x:Float, y:Float):Void {}
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
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
