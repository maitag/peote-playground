package;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.Image;

import peote.view.*;


class Main extends Application
{
	override function onWindowCreate():Void
	{
		if (switch (window.context.type) {case WEBGL, OPENGL, OPENGLES: false; default: true;})
			throw("Sorry, only works with OpenGL.");
		
		var peoteView = new PeoteView(window);

		var display = new Display(0, 0, window.width, window.height, Color.GREEN);
		peoteView.addDisplay(display);
		
		var buffer = new Buffer<Number>(1024, 512);

		var program = new Program(buffer);
		display.addProgram(program);

		utils.Loader.image("assets/peote_font.png", true, function(image:Image)
		{
			var texture = new Texture(image.width, image.height);
			texture.setData(image);
			// Halfw. i am think i am have it NOW ...
			texture.tilesX = 16;
			texture.tilesY = 16;
			// ok, i am think WE have it (^_^)
			
			program.addTexture(texture, "custom");
			// half ... shit -> i am forgot:
			program.injectIntoVertexShader(true); //((wtf*lol))	
			program.setFormula("n", "n + mod(uTime*2.0*precision, 5.0)");

			// ok ,,, .> lets try ...
			peoteView.start(); // \o/ *hugs all haxe m o n ks °^°;)~
		});
		
		// SPAWN: Halfwheat, i am really DO it NOW \o/
		// Laura, lets start the simplest ABIRTRARY NUMBERCOUNTER-> NOW 
		// SINCE -> a   a   aaaaaaaaaaaaaaa -> NY ;:)T I M E !!!
		var firstTestNumber = new Number(1, 10, 10, 100, 100, Color.GREEN);
		buffer.addElement(firstTestNumber);
		var secondTestNumber = new Number(10, 100, 10, 100, 100, Color.GREEN);
		buffer.addElement(secondTestNumber);
	}
	
	// ----------------- TIME EVENTS ------------------------------
	// override function update(deltaTime:Int):Void {}
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
