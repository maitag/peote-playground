package;

import openfl.display.OpenGLRenderer;
import openfl.display.Sprite;
import openfl.events.RenderEvent;
import openfl.events.Event;
import openfl.Lib;

import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Element;
import peote.view.Texture;
import peote.view.Color;
import utils.Loader;


class Main extends Sprite {
	
	var peoteView:PeoteView;

	public function new()
	{		
		super();
		x = 0;
		y = 0;
		addEventListener (RenderEvent.RENDER_OPENGL, renderOpenGL);
		addEventListener(Event.ENTER_FRAME, enterFrame);
		
		// addEventListener( Event.RESIZE, resize);
		Lib.current.stage.addEventListener( Event.RESIZE, resize);
		
		initPeoteView();
	}
	
	private function initPeoteView():Void
	{
		peoteView = new PeoteView(Lib.application.window, false);
		
		var display = new Display(0, 0, 800, 600, Color.BLUE);
		peoteView.addDisplay(display); // display to peoteView
		
		var buffer  = new Buffer<PeoteSprite>(100);
		var program = new Program(buffer);
		
		Loader.image ("assets/openfl.png", true, function (image:Image) 
		{
			var texture = new Texture(image.width, image.height);
			texture.setData(image);
			program.setTexture(texture, "custom");
			program.discardAtAlpha(0.2);
			
			display.addProgram(program); // programm to display
			
			var element  = new PeoteSprite(0, 0, image.width, image.height);
			buffer.addElement(element); // element to buffer
		});
		
		
	}
	
	private function enterFrame(event:Event):Void
	{
		invalidate();
	}
	
	public function resize(event:Event):Void
	{
		peoteView.resize(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
	}
	
	private function renderOpenGL (event:RenderEvent):Void
	{
		peoteView.renderPart();
	}
	
	
	
}



// ------- custom displayobject for peote-view ------

class PeoteSprite implements Element
{
	@posX public var x:Int = 0;
	@posY public var y:Int = 0;
	
	@sizeX public var w:Int = 100;
	@sizeY public var h:Int = 100;
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100 )
	{
		x = positionX;
		y = positionY;
		w = width;
		h = height;
	}
}
