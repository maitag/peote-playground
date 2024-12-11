package;

import lime.app.Application;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.graphics.Image;
import lime.graphics.ImageChannel;
import lime.math.Vector2;

import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Texture;
import peote.view.Element;

class Elem implements Element
{
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	//@color("bgCol")   public var bgCol  :Color = 0xffffffff;
	//@color("ringCol") public var ringCol:Color = 0x0000ffff;
	//@color("reelCol") public var reelCol:Color = 0x0000ffff;
	@color("objCol")  public var objCol :Color = 0x0000ffff;
	@color("mirrCol") public var mirrCol:Color = 0x0000ffff;
		
	// texture-slot
	@texSlot("object", "objmirr") public var variation:Int; // multiple objects+objectMirrors in multiple slots

	// tiles the slot or manual texture-coordinate into sub-slots
	@texTile("ring") @anim("wheelRotation", "repeat")
	public var ringFrame:Int; // Tiles for the reel
	
	@texTile("object", "objmirr") @anim("objectRotation", "repeat")
	public var objectFrame:Int; // Tiles per objects/objectMirrors

	//let the texture shift inside slot/texCoords/tile area
	@texPosX("object", "objmirr") @const public var tx:Int=48;
	@texPosY("object")  @anim("objectJump", "pingpong") public var posYObject:Int;
	@texPosY("objmirr") @anim("objectJump", "pingpong") public var posYObjmirr:Int;
	
	@texSizeX("object", "objmirr") @const public var sx:Int = 81; 
	@texSizeY("object", "objmirr") @const public var sy:Int = 56; 
	
	// formula (glsl) to combine colors with textures
	var DEFAULT_COLOR_FORMULA = 
		"mix(mix(mix(mix(background, ring, ring.a), reel, reel.a), objmirr*mirrCol, objmirr.a*reel.a), object*objCol, object.a)";
	
	// give the texture identifiers a default value ( if there is no texture set for )
	var DEFAULT_FORMULA_VARS = [
		"background"  => 0x00000000,
		"ring"        => 0x00000000,
		"reel"        => 0x00000000,
		"objmirr"     => 0x00000000,
		"object"      => 0x00000000,
	];
	
	var OPTIONS = { blend:false };
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, variation:Int )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.variation = variation;
		objCol.r = mirrCol.r = Std.int( 210 + Math.random()*15);
		objCol.g = mirrCol.g = Std.int( 210 + Math.random()*25);
		objCol.b = mirrCol.b = Std.int( 220 + Math.random()*35);
		objCol.alpha = 255;
		mirrCol.alpha = 235;
	}

}

class ShowreelGrid extends Application
{
	var peoteView:PeoteView;
	var element = new Array<Elem>();
	var buffer:Buffer<Elem>;
	var display:Display;
	var program:Program;
	
	var textureBackground:Texture;
	var textureRing:Texture;
	var textureReel:Texture;
	var textureObject:Texture;
	var textureObjMirr:Texture;
	
	var maxVariation = 5;
	var hElems:Int = 4;
	var vElems:Int = 4;
	var maxElements:Int;
	
	public override function onWindowCreate():Void
	{		
		if (switch(window.context.type) {case WEBGL,OPENGL,OPENGLES:false; default:true;}) throw("Sorry, only works with OpenGL.");

		maxElements = hElems * vElems;
		
		peoteView = new PeoteView(window);
		display   = new Display(10,10, window.width-20, window.height-20);
		peoteView.addDisplay(display);  // display to peoteView
		
		buffer  = new Buffer<Elem>(maxElements);
		program = new Program(buffer);
		display.addProgram(program);    // programm to display
		
		textureBackground = new Texture( 400,  256, 1, {mipmap:true, smoothExpand:true, smoothShrink:true, smoothMipmap:true} );
		textureRing       = new Texture(1600, 1024, 1, {mipmap:true, smoothExpand:true, smoothShrink:true, smoothMipmap:true, tilesX:4, tilesY:4});
		textureReel       = new Texture( 400,  256, 1, {mipmap:true, smoothExpand:true, smoothShrink:true, smoothMipmap:true});
		textureObject     = new Texture(3960, 780, maxVariation, {mipmap:true, smoothExpand:true, smoothShrink:true, smoothMipmap:true, maxTextureSize:4096, tilesX:22, tilesY:6}); 
		textureObjMirr    = new Texture(3960, 780, maxVariation, {mipmap:true, smoothExpand:true, smoothShrink:true, smoothMipmap:true, maxTextureSize:4096, tilesX:22, tilesY:6});
		
		program.autoUpdateTextures = false;
		program.setTexture(textureBackground, Elem.TEXTURE_background);
		program.setTexture(textureRing      , Elem.TEXTURE_ring);
		program.setTexture(textureReel      , Elem.TEXTURE_reel);
		program.setTexture(textureObject    , Elem.TEXTURE_object);
		program.setTexture(textureObjMirr   , Elem.TEXTURE_objmirr);
		
		program.discardAtAlpha(null);
		//program.setFragmentFloatPrecision("highp");
		program.updateTextures();
		
		var path = "assets/showreel";
		loadImage(textureBackground, '$path/background.jpg');
		loadImagePair(textureRing, '$path/ring_RGB.jpg', '$path/ring_Alpha.png');
		loadImage(textureReel, '$path/mirror_RGBA.png');
		
		for (i in 0...maxVariation) {
			loadImagePair(textureObject,  '$path/obj_0${i+1}_RGB.jpg', '$path/obj_0${i+1}_Alpha.png', i);
			loadImagePair(textureObjMirr, '$path/obj-mirror_0${i+1}_RGB.jpg', '$path/obj-mirror_0${i+1}_Alpha.png', i);
		}
		
		// create elements
		for (y in 0...vElems)
			for (x in 0...hElems) {
				var i = y * hElems + x;
				element[i] = new Elem(x * 400, y * 260, 400, 260, i % maxVariation);
				
				var speed:Int = Std.int(200 + Math.random() * 300);
				var reverse:Bool = (Math.random() > 0.5) ? true : false;
				
				if (reverse) element[i].animWheelRotation(15, 0); else element[i].animWheelRotation(0, 15);
				element[i].timeWheelRotation(0.0, speed/1000);
				
				if (reverse) element[i].animObjectRotation(127, 0); else element[i].animObjectRotation(0, 127);
				element[i].timeObjectRotation(0.0, speed/1000 * 16);
				
				var jumpheight = Std.int(5 + Math.random() * 25);
				element[i].animObjectJump(25, 65, 25-jumpheight, 65+jumpheight);
				element[i].timeObjectJump(Math.random() * 2, 1.5 + Math.random() * 2);
				
				buffer.addElement(element[i]);     // element to buffer
			}
					
		peoteView.start();		
	}
	
	// load first the rgb data into image (as jpg)
	public function loadImagePair(texture:Texture, fnRGB:String, fnAlpha:String, slot:Int=0):Void {
		trace('load RGB-image $fnRGB');
		var future = Image.loadFromFile(fnRGB);
		future.onProgress (function (a:Int,b:Int) trace ('...loading image $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (image:Image) {
			trace('loading $fnRGB complete');
			loadImageAlpha(texture, image, fnAlpha, slot);
		});		
	}
	function loadImageAlpha(texture:Texture, imgRGB:Image, fnAlpha:String, slot:Int=0):Void {
		trace('load Alpha-image $fnAlpha');
		var future = Image.loadFromFile(fnAlpha);
		future.onProgress (function (a:Int,b:Int) trace ('...loading image $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (image:Image) {
			trace('loading $fnAlpha complete');
			// copy alphachannel
			imgRGB.copyChannel(image, image.rect, new Vector2(0, 0), ImageChannel.RED, ImageChannel.ALPHA);			
			texture.setData(imgRGB, slot);
		});		
	}
	// -------------------------------------------------
	
	// load normal image
	public function loadImage(texture:Texture, filename:String, slot:Int=0):Void {
		trace('load image $filename');
		var future = Image.loadFromFile(filename);
		future.onProgress (function (a:Int,b:Int) trace ('...loading image $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (image:Image) {
			trace('loading $filename complete');
			texture.setData(image, slot);
		});		
	}
	
	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.F: window.fullscreen = !window.fullscreen;
			case KeyCode.NUMPAD_PLUS:  display.zoom+=0.1;
			case KeyCode.NUMPAD_MINUS: display.zoom -= 0.1;
			case KeyCode.UP: display.yOffset -= (modifier.shiftKey) ? 8 : 1;
			case KeyCode.DOWN: display.yOffset += (modifier.shiftKey) ? 8 : 1;
			case KeyCode.RIGHT: display.xOffset += (modifier.shiftKey) ? 8 : 1;
			case KeyCode.LEFT: display.xOffset -= (modifier.shiftKey) ? 8 : 1;
			default:
		}
	}

	override function onWindowResize(width:Int, height:Int)
	{
		// peoteView.resize(width, height);
		display.width  = width - 20;
		display.height = height - 20;
		#if android
		/*
		element.w = display.width;
		element.h = Std.int(256 / 400 * display.width);
		buffer.updateElement(element);
		*/
		#end
	}

}
