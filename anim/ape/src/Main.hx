package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.Image;

import peote.view.*;
import utils.Loader;

class ElementTexSlot implements Element
{
	// position
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	@sizeX @const public var w:Int=490;
	@sizeY @const public var h:Int=224;

	public var aspectRatio(get, never):Float;
	inline function get_aspectRatio():Float return w/h;

	@texSlot @anim("Slot", "pingpong")var slot:Int = 0;

	// color
	// Half, lets pls also make some ANIMATION here:
	// @color @anim("Color", "pingpong")
	public var c:Color = 0xffff88ff;
		
	public function new() {}
}

class Main extends Application
{
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

	var display:Display;
	var buffer:Buffer<ElementTexSlot>;
	var element:ElementTexSlot;

	public function startSample(window:Window)
	{
		var peoteView = new PeoteView(window);

		// a new Display what have to allways fully fit into the View-AspectRation
		display = new Display(0, 0, window.width, window.height, Color.BLACK);		
		// initializing the displays position, size and zoom
		onWindowResize( window.width, window.height );
		
		// buffer to store exactly one Element
		buffer = new Buffer<ElementTexSlot>(1);

		// create program and one great texture to hold 16 images into slots
		var program = new Program(buffer);
		var texture = new Texture(490, 224, 16);
		program.addTexture(texture, "base");

		// add the Display to the View and the Program to the Display
		peoteView.addDisplay(display);
		display.addProgram(program);

		// create only one element what is using a texture-slot
		element = new ElementTexSlot();
		buffer.addElement(element);
		

		// loads all images into the corresponding texture-slot and starts the Animation afterwards
		Loader.imageArray
		(
			[for (i in 0...16) 'assets/crop$i.jpg'],
			// true, // debug output
			function (index:Int, image:Image) // after every images is loades
			{
				texture.setData(image, index);
			},
			function (_) // after all images is loaded (param normally there for is the complete array of images)
			{
				// anim position from xy (0,0) to xy (700,0)
				element.animSlot(0, 15);
				element.timeSlot(0.0, 1.2); // from start-time (0.0) and during 1 seconds 
				
				// animate Color from red to yellow
				// element.animCol(Color.RED, Color.GREEN);
				// element.timeCol(0.0, 1.0); // from start-time (0.0) and during 1 seconds
				
				// don't forget to update all this changes!
				buffer.updateElement(element);
				
				
				peoteView.start(); // after this the "peote time" counts up !
				
				
				// after 1 second delay via haxe-Timer its is start changing color also
				/*
				haxe.Timer.delay(
					function() {
						element.animCol(Color.GREEN, Color.BLUE); // from green to blue
						element.timeCol(peoteView.time, 2.0); // from actual time and during 2 seconds
						buffer.updateElement(element); // don't forget to "update" !
					},
					1000
				);
				*/
			}
		);


	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// override function onPreloadComplete():Void {}

	// override function update(deltaTime:Int):Void {}

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
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}	
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	override function onWindowResize (width:Int, height:Int):Void
	{
		display.width = width;
		display.height = height;
		
		var viewAspectRatio:Float = width/height;

		// zooming Display content and moving the Display in depend of image-ratio an size
		
		trace("view AspectRatio   ", viewAspectRatio);
		trace("element aspectRatio", element.aspectRatio);
		
		// little H  E  L  P  E  R (for l a t e r ;:)~~~
		/*
		var sameBias:Float->Float->Bool = function(ratioA:Float, ratioB:Float):Bool {
			if (viewAspectRatio >= 1 && element.aspectRatio >= 1 || viewAspectRatio < 1 && element.aspectRatio < 1)
				return true;
			else return false;
		}
		*/

		display.zoom = width / element.w; 

		// reposition (all out of "bias" at now!!!!)
		display.yOffset = ((display.height - element.h*display.zoom)/2);
	}


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
