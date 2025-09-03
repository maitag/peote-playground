package;

import peote.view.Color;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.Image;

import peote.view.*;

class Main extends Application
{
	var peoteView:PeoteView;

	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);

		var total_elements = 2000;
		var buffer = new Buffer<AnimTileSprite32x32>(total_elements, total_elements, true);
		var display = new Display(0, 0, window.width, window.height);
		var program = new Program(buffer);

		peoteView.addDisplay(display);
		display.addProgram(program);

		var texture = new Texture(256, 96);
		texture.tilesX = 8;
		texture.tilesY = 3;

		Load.image("assets/walk.png", true, function(image:Image) {
			texture.setData(image);
		});

		program.addTexture(texture, "custom");

		var y_offset = display.height / total_elements;
		
		var distance_of_walk = display.width + 128;
		var frame_count = 24;
		var cycles_count = (window.width * 2) / frame_count;

		var colors:Array<Array<Color>> = [
			[0xff8080ff, 0x80ff80ff ],
			[0x80ff80ff, 0x8080ffff ],
			[0x8080ffff, 0xff8080ff ],
			[0xd99343ff, 0x7943d9ff ],
			[0x5da7fcff, 0xe4fc5dff ],
			[0x92fc5dff, 0xfc8d5dff ],
		];

		for(n in 0...total_elements)
		{
			var sprite = new AnimTileSprite32x32();
			
			var x_offset = random_int(0, 32);
			var is_walking_to_right = n % 2 == 0;
			
			// start x position off screen to left or right alternatively
			var x = is_walking_to_right ? -32 - x_offset : display.width + x_offset;

			// start y positions along y axis from top to bottom
			var y = Std.int(y_offset * n);
			
			// put at y position (no animation there!)
			sprite.y = y;
				
			// anim tiles for walk cycle ---------------------------------------------------------
			var walkcycle_duration = frame_count / random_int(6, 24);
			sprite.animTile(0, frame_count - 1); // start tile, end tile
			sprite.timeTile(0.0, walkcycle_duration); // start time, end time
			
			// anim position ---------------------------------------------------------------------
			var from = x;
			var to = is_walking_to_right ? x + distance_of_walk : x - distance_of_walk ;
			sprite.animPos( Std.int(from), Std.int(to) ); // start/end of x position
			
			var walk_time_start = random_int(1, 60);
			var walk_time_duration = walk_time_start + cycles_count * walkcycle_duration;
			sprite.timePos(walk_time_start, walk_time_duration); // start time, duration
						
			// anim color ------------------------------------------------------------------------
			var color_index = random_int(0, colors.length - 1);
			sprite.animCol(colors[color_index][0], colors[color_index][1]); // color at start, color at end
			sprite.timeCol(walk_time_start, walk_time_duration / 3);
			
			// don't forget to add it to the buffer!
			buffer.addElement(sprite);	
		}

		peoteView.start(); // after this the "peote time" counts up !
	
	}
	
	inline function random_int(min:Int, max:Int):Int {
		return Std.int(min + Math.random() * (max - min));
	}

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// override function onPreloadComplete():Void {
		// access embeded assets from here
	// }

	// override function update(deltaTime:Int):Void {
		// for game-logic update
	// }

	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");		

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
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	// override function onWindowLeave():Void { trace("onWindowLeave"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
}