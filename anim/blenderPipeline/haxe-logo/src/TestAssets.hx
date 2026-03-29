package;

import haxe.Timer;
import lime.ui.*;
import peote.view.*;

import assets.Pipeline;

class TestAssets extends lime.app.Application
{
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	var peoteView:PeoteView;
	var buffer:Buffer<ElemAnim>;
	var display:Display;
	var program:Program;
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		display   = new Display(0,0, window.width, window.height, Color.RED1);
		peoteView.addDisplay(display);
		
		buffer  = new Buffer<ElemAnim>(100);
		program = new Program(buffer);
		program.blendEnabled = true;

		display.addProgram(program);
		
		program.setMultiTexture(PipelineTools.loadTextures(Pipeline.sheets), "custom");
		
		ElemAnim.init(buffer, Pipeline.tiles);

		var x:Int = 20;
		var y:Int = 0;
		for (tileName => tile in Pipeline.tiles) {
			for (animName => anim in tile.anim) {
				var elem = new ElemAnim(x, y, tileName);
				
				// TODO: fps from blender for the duration
				var duration = 2.5;
				elem.play(animName, 0, duration);
				var timer = new Timer(3000);
				// timer.run = elem.play.bind(animName, peoteView.time, duration);
				timer.run = ()->{
					elem.play(animName, peoteView.time, duration);
				}

				x += tile.width;
			}
		}

		// -> don't forget to start peoteViews timer <-
		peoteView.start();
	}
	
	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}	
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}
	
}
