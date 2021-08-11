package;

import lime.app.Application;
import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Texture;
import peote.view.Color;

import utils.Loader;

class Main extends Application
{	
	override function onWindowCreate():Void
	{		
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				
				var peoteView = new PeoteView(window, Color.GREY3);

				var display = new Display(0, 0, 800, 590, Color.GREY6);
				
				var buffer = new Buffer<Semmi>(4, 4, true);
				var program = new Program(buffer);
				
				Loader.image("assets/semmi_colors_by_yenoPenn.png", true, function(image:Image)
				{
					var texture = new Texture(image.width, image.height);
					texture.setImage(image);
					
					program.addTexture(texture, "custom");					
					program.snapToPixel(1); // for smooth animation

					peoteView.addDisplay(display);
					display.addProgram(program);
					
					buffer.addElement(new Semmi(0, 0, peoteView.time));
					
					peoteView.start();
				});				
				
			default: throw("Sorry, only works with OpenGL.");			
		}		
	}		

}
