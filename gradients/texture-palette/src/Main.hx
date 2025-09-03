package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.Image;

import peote.view.*;


/**

	Simple palette texture look up - James Fisher 2022

**/

class Elem implements Element
{
	@posX public var x:Int;
	@posY public var y:Int;
	
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int, height:Int, c:Int=0xFF0000FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
	}
}

class Main extends Application
{
	var peoteView:PeoteView;
	var display:Display;
	
	var bufferPalette:Buffer<Elem>;
	var programPalette:Program;
	var paletteTexture:Texture;
	var elementPalette:Elem;
	
	var bufferSprite:Buffer<Elem>;
	var programSprite:Program;
	var spriteTexture:Texture;
	var elementSprite:Elem;

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

	public function startSample(window:Window)
	{	
		peoteView = new PeoteView(window);
		display   = new Display(10,10, window.width-20, window.height-20, Color.GREY1);
		peoteView.addDisplay(display);
		
		bufferPalette  = new Buffer<Elem>(1);
		programPalette = new Program(bufferPalette);
		display.addProgram(programPalette);
		
		bufferSprite  = new Buffer<Elem>(1);
		programSprite = new Program(bufferSprite);
		display.addProgram(programSprite);
		
		var colors = [
			0x000000ff,
			0x0000AAff,
			0x00AA00ff,
			0x00AAAAff,
			0xAA0000ff,
			0xAA00AAff,
			0xAA5500ff,
			0xAAAAAAff,
			0x555555ff,
			0x5555FFff,
			0x55FF55ff,
			0x55FFFFff,
			0xFF5555ff,
			0xFF55FFff,
			0xFFFF55ff,
			0xFFFFFFff,
		];
		
		// init palette texture, generating Image procedurally
		paletteTexture = new Texture(colors.length, colors.length);
		paletteTexture.setData(generatePaletteImage(colors), 0);
		programPalette.setTexture(paletteTexture, "base");

		// show palette element
		elementPalette  = new Elem(0, 0, colors.length, colors.length);
		bufferPalette.addElement(elementPalette);

		// resize palette element so it is visible (otherwise is only 16 x 1 pixels)
		elementPalette.w = display.width;
		elementPalette.h *= 64;
		bufferPalette.updateElement(elementPalette);
		
		Load.image("assets/circle-greys-rgba.png", true, function(image:Image) {

			// init grayscale texture with Image loaded from disk
			spriteTexture = new Texture(image.width, image.height);
			spriteTexture.setData(image, 0);
			
			// set graycale and palette texture in sprite program
			programSprite.setTexture(spriteTexture, "base");
			programSprite.setTexture(paletteTexture, "palette");

			// inject palette sampler code
			programSprite.injectIntoFragmentShader("
				vec4 colorFramPalette(int textureID, int paletteID)
				{
					// sample sprite texture
					vec4 texColor = getTextureColor(textureID, vTexCoord);
					
					// determine luminosity of sample
					float luminosity = 0.21 * texColor.r + 0.71 * texColor.g + 0.07 * texColor.b;
					
					// use luminosity value for position
					vec2 paletteCoord = vec2(luminosity, 0.0);
					
					// return rgb from palette texture sample
					// alpha from sprite texture sample
					return vec4(getTextureColor(paletteID, paletteCoord).rgb, texColor.a);
				}
			");
			programSprite.setColorFormula('colorFramPalette(base_ID, palette_ID)');

			// show grayscale element
			var x = Std.int(display.width * 0.5 - image.width * 0.5);
			var y = Std.int(display.height * 0.5 - image.height * 0.5);
			elementSprite = new Elem(x, y, image.width, image.height);
			bufferSprite.addElement(elementSprite);

			peoteView.start();
		});	
	}

	function generatePaletteImage(colors:Array<Int>):Image{
		var image = new Image(null, 0, 0, colors.length, 1, 0xffffffff);
		for (i => color in colors) image.setPixel32(i, 0, color);
        return image;
	}
}
