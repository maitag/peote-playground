package;

import peote.net.Remote;
import ServerRemote;

import peote.io.Byte;
import peote.io.UInt16;

#if lime
import haxe.ds.IntMap;
import haxe.ds.Vector;
import lime.ui.Window;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Display;
import peote.view.Program;
import peote.view.Texture;
import peote.view.Color;


class ClientRemote implements Remote {
	
	var client:Client;
	
	var width:Int;
	var height:Int;
	
	var peoteView:PeoteView;
	var textureCanvas:Texture; // texture to draw into

	var displayCanvas:Display;
	var bufferCanvas:Buffer<ElemCanvas>;
	var programCanvas:Program;
	
	var displayDraw:Display;
	var bufferDraw:Buffer<ElemPen>;
	var programDraw:Program;
	
	var displayPen:Display;
	var bufferPen:Buffer<ElemPen>;
	var programPen:Program;
	
	var penMap = new IntMap<ElemPen>();

	
	//public var server:ServerRemoteRemoteClient = null; // <- problem with Remote macro (type can not be ready generated)!
	public var server = (null : ServerRemoteRemoteClient);

	public function new( window:Window, width:Int=800, height:Int=600, client:Client ) {
		
		this.width = width;
		this.height = height;
		this.client = client;
		
		// ------ delegate Lime mouse and keyboard events ------
		
		window.onMouseMove.add(mouseMove);
		window.onMouseUp.add(mouseUp);
		window.onMouseDown.add(mouseDown);
		window.onMouseWheel.add(mouseWheel);
		//window.onKeyDown.add(keyDownActive);
		//window.onKeyDown.add(keyUpActive);		
		
		
		
		// ------ initialize peote-view --------
		
		peoteView = new PeoteView(window);

		// --- texture to render into ---		
		textureCanvas = new Texture(width, height);
		// do not clear the texture before rendering into (only color, depth and stencil is cleaned)
		textureCanvas.clearOnRenderInto = false;
		

		// --- display that holds elements with the texture what is drawed into ---
		displayCanvas = new Display(0, 0, width, height, Color.BLUE);
		peoteView.addDisplay(displayCanvas);
		
		bufferCanvas  = new Buffer<ElemCanvas>(2);
		
		programCanvas = new Program(bufferCanvas);		
		programCanvas.setTexture(textureCanvas, "renderFrom");
		//programCanvas.setColorFormula('renderFrom');
		programCanvas.alphaEnabled = true;
		programCanvas.discardAtAlpha(null);
		
		displayCanvas.addProgram(programCanvas);
		
		var elemCanvas = new ElemCanvas(width, height);
		bufferCanvas.addElement(elemCanvas);
		
		
		// --- display to render into the texture for canvas ---		
		displayDraw = new Display(0, 0, width, height);
		//peoteView.addDisplay(displayDraw);
		
		//peoteView.addFramebufferDisplay(displayDraw); // add also to the hidden RenderList for updating the Framebuffer Textures
		//displayDraw.renderFramebufferSkipFrames = 2; // at 1/3 framerate (after render a frame skip 2)
		//displayDraw.renderFramebufferEnabled = false;
		
		bufferDraw  = new Buffer<ElemPen>(1024, 512);
		programDraw = new Program(bufferDraw);
		
		displayDraw.addProgram(programDraw);
		displayDraw.setFramebuffer(textureCanvas, peoteView); // texture to render into
		
		
		// --- display to render the pens only ---		
		displayPen = new Display(0, 0, width, height);
		peoteView.addDisplay(displayPen);
		
		bufferPen  = new Buffer<ElemPen>(16, 8);
		programPen = new Program(bufferPen);
		
		displayPen.addProgram(programPen);

		//peoteView.start();
	}
	
	public function serverRemoteIsReady( server ) {
		// trace(Type.typeof(server));
		this.server = server;
	}
	
	var moveTime:Float = 0;
	static inline var timeDelay:Float = 0.02;
	
	inline function move(x:Int, y:Int) {
		//trace("move", x, y);
		if (haxe.Timer.stamp() < moveTime) {
			//trace("queue");

		}
		else {
			moveTime = haxe.Timer.stamp() + timeDelay;			
			if (server != null) {
				//trace("send");
				server.penMove(x, y);
			}
		}
		
	}
	
	var drawQueue = new Array<UInt16>();
	var drawQueueTime:Float = 0;
	
	inline function draw(x:Int, y:Int) {
		//trace("draw", x, y);
		if (haxe.Timer.stamp() < drawQueueTime) {
			//trace("queue");
			drawQueue.push(Std.int(x));
			drawQueue.push(Std.int(y));
		}
		else {
			drawQueueTime = haxe.Timer.stamp() + timeDelay;
			if (drawQueue.length != 0 && server != null) {
				//trace("send");
				var lastX = drawQueue[drawQueue.length - 2];
				var lastY = drawQueue[drawQueue.length - 1];
				server.penDraw(drawQueue);
				drawQueue.resize(2);
				drawQueue[0] = lastX;
				drawQueue[1] = lastY;
			}
		}
		
	}
	
	// ------------------------------------------------------------
	// ------------ Delegated LIME EVENTS -------------------------
	// ------------------------------------------------------------	
	var isDraw = false;
	
	// TODO: transfer only the relative movements into Bytes!
	inline function mouseMove(x:Float, y:Float) {
		//trace("mouseMove", x, y);
		var _x:Int = (x < 0) ? 0 : Std.int(x);
		var _y:Int = (y < 0) ? 0 : Std.int(y);
		if (isDraw) draw(_x, _y) else move(_x, _y);
		
	}
	inline function mouseDown(x:Float, y:Float, button:MouseButton) {
		//trace("mouseDown", x, y, button);
		isDraw = true;
		drawQueue.push(Std.int(x));
		drawQueue.push(Std.int(y));
		drawQueueTime = haxe.Timer.stamp() + timeDelay;
	}
	inline function mouseUp(x:Float, y:Float, button:MouseButton) {
		//trace("mouseUp", x, y, button);
		isDraw = false;
		
		if (drawQueue.length != 0 && server != null) {
			//trace("send");
			server.penDraw(drawQueue);
			drawQueue.resize(0);
		}
		
	}
	inline function mouseWheel(dx:Float, dy:Float, mode:MouseWheelMode) {
		//trace("mouseWheel",dx, dy, mode);
	}
			
	
	
	// ------------------------------------------------------------
	// ----- Functions that run on Client and called by Server ----
	// ------------------------------------------------------------
	
	@:remote public function addPen(userNr:UInt16):Void {
		trace('Client: addPen - userNr:$userNr');		
		var pen = new ElemPen();
		bufferPen.addElement(pen);		
		penMap.set(userNr, pen);
	}
	
	@:remote public function removePen(userNr:UInt16):Void {
		trace('Client: removePen - userNr:$userNr');		
		var pen = penMap.get(userNr);
		if (pen != null) {
			bufferPen.removeElement(pen);
			penMap.remove(userNr);
		}
	}
	
/*	@:remote public function changePen(userNr:UInt16, penParam:PenParam):Void {
		trace('Client: changePen - userNr:$userNr, penNr:$penNr');
		penMap.set(userNr, availPen.get(penNr));
	}
*/	
	
	
	@:remote public function penMove(userNr:UInt16, x:UInt16, y:UInt16):Void {
		//trace('Client: penMove - userNr:$userNr');
		var pen = penMap.get(userNr);
		if (pen != null) {
			pen.x = x;
			pen.y = y;
			bufferPen.updateElement(pen);
		}
	}

	@:remote public function penDraw(userNr:UInt16, drawQueue:Array<UInt16>):Void {
		//trace('Client: penDraw - userNr:$userNr');
		
		for ( i in 0...Std.int(drawQueue.length/2) ) {
			bufferDraw.addElement(new ElemPen(drawQueue[i*2], drawQueue[i*2 + 1] ));
			if (i > 0)  {
				var dx:Float = -drawQueue[i*2] + drawQueue[(i - 1)*2];
				var dy:Float = -drawQueue[i*2 + 1] + drawQueue[(i - 1)*2 + 1];
				var distance = Math.max(Math.abs(dx), Math.abs(dy));
				for ( j in 1...Std.int(distance) )
					bufferDraw.addElement(new ElemPen(Std.int(drawQueue[i*2]+dx*j/distance), Std.int(drawQueue[i*2 + 1]+dy*j/distance)));
			}
		}
		
		peoteView.renderToTexture(displayDraw);
		
		// clear
		for (i in 0...bufferDraw.length()) bufferDraw.removeElement(bufferDraw.getElement(i));
		// TODO: need to upgrade peote-view:
		// bufferDraw.removeAllElements();
		// bufferDraw._maxElements = 0;
		
		penMove(userNr, drawQueue[drawQueue.length-2], drawQueue[drawQueue.length-1]);
	}

}


#else

// need for dedicated server to build without lime
class ClientRemote implements Remote {
	@:remote public function addPen(userNr:UInt16) {}
	@:remote public function removePen(userNr:UInt16) {}
	@:remote public function penMove(userNr:UInt16, x:UInt16, y:UInt16) {}
	@:remote public function penDraw(userNr:UInt16, drawQueue:Array<UInt16>) {}
}

#end