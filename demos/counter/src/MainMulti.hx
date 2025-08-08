package;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.Image;

import peote.view.*;

class MainMulti extends Application
{
	var peoteView:PeoteView;
	var buffer:Buffer<Cypher>;

	var speedBin:UniformFloat;
	var speedOct:UniformFloat;
	var speedDec:UniformFloat;
	var speedHex:UniformFloat;

	override function onWindowCreate():Void
	{
		if (switch (window.context.type) {case WEBGL, OPENGL, OPENGLES: false; default: true;})
			throw("Sorry, only works with OpenGL.");
		
		peoteView = new PeoteView(window);

		// SPAWN 6x5 Cyphers into ONE buffer
		buffer = new Buffer<Cypher>(30);
		for (y in 0...5) {
			for (x in 0...6) {
				buffer.addElement(new Cypher(y*6 + x, 50 + x*50, 25 + y*50, 50, 50, Color.random(255) ) );
			}
		}
		
		var displayBin = new Display(    0,   0, 400, 300, Color.GREEN2);
		var displayOct = new Display(  400,   0, 400, 300, Color.RED2);
		var displayDec = new Display(    0, 300, 400, 300, Color.ORANGE);
		var displayHex = new Display(  400, 300, 400, 300, Color.LIME);

		peoteView.addDisplay(displayBin);
		peoteView.addDisplay(displayOct);
		peoteView.addDisplay(displayDec);
		peoteView.addDisplay(displayHex);
		
		var programBin = new Program(buffer);
		var programOct = new Program(buffer);
		var programDec = new Program(buffer);
		var programHex = new Program(buffer);
				
		displayBin.addProgram(programBin);
		displayOct.addProgram(programOct);
		displayDec.addProgram(programDec);
		displayHex.addProgram(programHex);

		
		speedBin = new UniformFloat("uSpeed", 1.0);
		speedOct = new UniformFloat("uSpeed", 1.0);
		speedDec = new UniformFloat("uSpeed", 1.0);
		speedHex = new UniformFloat("uSpeed", 1.0);


		utils.Loader.image("assets/peote_font.png", true, function(image:Image)
		{
			var texture = new Texture(image.width, image.height);
			texture.setData(image);
			
			texture.tilesX = 16;
			texture.tilesY = 16;
			
			programBin.addTexture(texture);
			programOct.addTexture(texture);
			programDec.addTexture(texture);
			programHex.addTexture(texture);
			
			programBin.injectIntoVertexShader(true, [speedBin]);
			programOct.injectIntoVertexShader(true, [speedOct]);
			programDec.injectIntoVertexShader(true, [speedDec]);
			programHex.injectIntoVertexShader(true, [speedHex]);
			
			programBin.setFormula("n", "48.0 + mod(uTime * min(  pow(  2.0, precision) * uSpeed * 1.0e-15 , 200.0  ),  2.0)");
			programOct.setFormula("n", "48.0 + mod(uTime * min(  pow(  8.0, precision) * uSpeed * 1.0e-28 , 800.0  ),  8.0)");
			programDec.setFormula("n", "48.0 + mod(uTime * min(  pow( 10.0, precision) * uSpeed * 1.0e-30 , 1000.0  ), 10.0)");
			programHex.setFormula("n", "48.0 + mod(uTime * min(  pow( 16.0, precision) * uSpeed * 1.0e-36 , 1600.0  ), 16.0)
			+ (( mod(uTime * min(  pow( 16.0, precision) * uSpeed * 1.0e-36 , 1600.0  ), 16.0) < 10.0) ? 0.0 : 7.0)
			");

			peoteView.start();	
			peoteView.time = 5.0; // play a bit forward at start
			window.onRender.add(_render);
		});

	}

	function _render(_):Void {
		speedBin.value *= 1.004;
		speedOct.value *= 1.005;
		speedDec.value *= 1.01;
		speedHex.value *= 1.008;
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
