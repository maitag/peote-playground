package;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Texture;
import peote.view.Color;
import utils.Loader;

import lime.graphics.Image;

class Main extends lime.app.Application
{
	var peoteView:PeoteView;
	
	public function new() super();
	
	public override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES: 
				
				peoteView = new PeoteView(window.context, window.width, window.height);

				var buffer = new Buffer<Semmi>(4, 4, true);
				var display = new Display(0, 0, window.width, window.height, Color.GREY6);
				var program = new Program(buffer);
				
				Loader.image("assets/semmi_colors_by_yenoPenn.png", true, function(image:Image)
				{
					var texture = new Texture(image.width, image.height);
					texture.setImage(image);
					
					program.addTexture(texture, "custom");
					
					// for smooth animation:
					program.snapToPixel(1);

					peoteView.addDisplay(display);
					display.addProgram(program);
					
					buffer.addElement(new Semmi(0, 0, peoteView.time));
					
					peoteView.start();
				});
				
				
				
			default: throw("Sorry, only works with OpenGL.");
			
		}
	}
		
	// ------------------------------------------------------------
	
	public override function render(context:lime.graphics.RenderContext)  peoteView.render();
	public override function onWindowResize (width:Int, height:Int)       peoteView.resize(width, height);

}
