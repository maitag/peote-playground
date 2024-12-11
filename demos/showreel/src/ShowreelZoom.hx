package;
import lime.graphics.RenderContext;
import haxe.Timer;

import lime.ui.MouseWheelMode;
import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
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
	@posX @set("posSize") @anim("posSize", "repeat") public var x:Float;
	@posY @set("posSize") @anim("posSize", "repeat") public var y:Float;
	
	@sizeX @set("posSize") @anim("posSize", "repeat") public var w:Float;
	@sizeY @set("posSize") @anim("posSize", "repeat") public var h:Float;
	
	//@color("bgCol")   public var bgCol  :Color = 0xffffffff;
	//@color("ringCol") public var ringCol:Color = 0x0000ffff;
	//@color("reelCol") public var reelCol:Color = 0x0000ffff;
	@color("objCol")  public var objCol :Color = 0x0000ffff;
	@color("mirrCol") public var mirrCol:Color = 0x0000ffff;
		
	// texture-slot
	@texSlot("object", "objmirr") public var variation:Int; // multiple objects+objectMirrors in multiple slots

	// tiles the slot or manual texture-coordinate into sub-slots
	@texTile("ring") @anim("wheelRotation", "repeat")
	public var ringFrame:Int;
	
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
	
	public function new( variation:Int )
	{
		this.variation = variation;
		objCol.r = mirrCol.r = Std.int( 210 + Math.random()*15);
		objCol.g = mirrCol.g = Std.int( 210 + Math.random()*25);
		objCol.b = mirrCol.b = Std.int( 220 + Math.random()*35);
		objCol.alpha = 255;
		mirrCol.alpha = 235;
	}

}


class ShowreelZoom extends Application
{
	var peoteView:PeoteView;
	var display:Display;
	var display1:Display;
	var display2:Display;
	var program:Program;
	var program1:Program;
	var program2:Program;
	var buffer:Buffer<Elem>;
	var element = new Array<Elem>();
	
	var textureBackground:Texture;
	var textureRing:Texture;
	var textureReel:Texture;
	var textureObject:Texture;
	var textureObjMirr:Texture;
	
	var maxVariation = 5;
	var hElems:Int = 4;
	var vElems:Int = 4;
	var maxElements:Int = 0;
	
	public override function onWindowCreate():Void
	{			
		if (switch(window.context.type) {case WEBGL,OPENGL,OPENGLES:false; default:true;}) throw("Sorry, only works with OpenGL.");
	
		peoteView = new PeoteView(window);
		// multiple displays with different zoomlevels
		display  = new Display(10, 10, window.width - 20, window.height - 20);
		display1  = new Display(10, 10, window.width - 20, window.height - 20);
		display2  = new Display(10, 10, window.width - 20, window.height - 20);
		display2.xOffset = display1.xOffset = display.xOffset = Std.int((window.width-20)/2);
		display2.yOffset = display1.yOffset = display.yOffset = Std.int((window.height-20)/2);
		peoteView.addDisplay(display);
		peoteView.addDisplay(display1);
		peoteView.addDisplay(display2);
		
		buffer  = new Buffer<Elem>(1000);
		program = new Program(buffer);
		display.addProgram(program); 
		display1.addProgram(program);
		display2.addProgram(program);

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
		program.snapToPixel(1);
		program.discardAtAlpha(null);
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
		var w = 800.0;
		var h = 512.0;
		
		function getWOffset(z:Int):Float return w * z;
		function getHOffset(z:Int):Float return h * z;
		
		function getXOffset(z:Int):Float {
			var off:Float = 0;
			var start:Float = w;
			for (i in 0...z) {
				off -= z * start;
				start = start/2;
			}
			return off;
		}
		function getYOffset(z:Int):Float {
			var off:Float = 0;
			var start:Float = h;
			for (i in 0...z) {
				off -= z * start;
				start = start/2;
			}
			return off;
		}
		
		function sizeX(r:Int, z:Int):Float {
			var newSize:Float = getWOffset(z);
			for (i in 0...r) newSize /= 2.0;
			return newSize;
		}
		function offX(r:Int, z:Int):Float {
			var size:Float = getWOffset(z);
			var newOff:Float = getXOffset(z);
			for (i in 0...r) { newOff += size; size /= 2.0; }
			return newOff;
		}
		function sizeY(r:Int, z:Int):Float {
			var newSize:Float = getHOffset(z);
			for (i in 0...r) newSize /= 2.0;
			return newSize;
		}
		function offY(r:Int, z:Int):Float {
			var size:Float = getHOffset(z);
			var newOff:Float = getYOffset(z);
			for (i in 0...r) { newOff += size; size /= 2.0; }
			return newOff;
		}
		
		var rings = 5;
		var maxz = rings * 4;
		var speed = 10;
		for (ring in rings...rings+rings) {				
			for (y in 0...vElems)
				for (x in 0...hElems) {
					if ( ! (x > 0 && x < hElems-1 && y > 0 && y < vElems-1) ) {
						element[maxElements] = new Elem(maxElements % maxVariation);
						
						element[maxElements].setPosSize(
							(x * sizeX(ring, maxz) + offX(ring, maxz)),
							(y * sizeY(ring, maxz) + offY(ring, maxz)),
							(sizeX(ring, maxz)),
							(sizeY(ring, maxz))
						);
						
						/*
						element[maxElements].animPosSize(
							x * sizeX(ring, maxz) + offX(ring, maxz),
							y * sizeY(ring, maxz) + offY(ring, maxz),
							sizeX(ring, maxz),
							sizeY(ring, maxz),
							
							x * sizeX(ring-maxz, maxz) + offX(ring-maxz, maxz),
							y * sizeY(ring-maxz, maxz) + offY(ring-maxz, maxz),
							sizeX(ring-maxz, maxz),
							sizeY(ring-maxz, maxz)
						);
						*/
						element[maxElements].timePosSize(0, speed);
						
						// rotation
						var speed:Int = Std.int(200 + Math.random() * 300);
						var reverse:Bool = (Math.random() > 0.5) ? true : false;
				
						if (reverse) element[maxElements].animWheelRotation(15, 0); else element[maxElements].animWheelRotation(0, 15);
						element[maxElements].timeWheelRotation(0.0, speed/1000);
						
						if (reverse) element[maxElements].animObjectRotation(127, 0); else element[maxElements].animObjectRotation(0, 127);
						element[maxElements].timeObjectRotation(0.0, speed/1000 * 16);
						
						var jumpheight = Std.int(5 + Math.random() * 25);
						element[maxElements].animObjectJump(25, 65, 25-jumpheight, 65+jumpheight);
						element[maxElements].timeObjectJump(Math.random() * 2, 1.5 + Math.random() * 2);
				
						buffer.addElement(element[maxElements]);     // element to buffer
						maxElements++;
					}
				}
		}
					
		new Timer(40).run = zoom;

		peoteView.start();
	}
	
	// public override function render(context:RenderContext):Void zoom();
	
	var fz:Float = 0.002;
	var fz1:Float = 0.0319;
	var fz2:Float = 1.0;
	public function zoom()
	{	
		if (fz2 < 32) {
			fz  *= 1.005;
			fz1 *= 1.005;
			fz2 *= 1.005; 
		}
		else {
			fz = 0.002;
			fz1 = 0.0319;
			fz2 = 1.0;
		}
		display.zoom = fz;
		display2.zoom = fz2;
		display1.zoom = fz1;
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
			case KeyCode.SPACE: if (peoteView.isRun) peoteView.stop() else peoteView.start();
			default:
		}
	}
		
	override function onWindowResize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
		display.width  = width - 20;
		display.height = height - 20;
		display1.width  = width - 20;
		display1.height = height - 20;
		display2.width  = width - 20;
		display2.height = height - 20;

		display2.xOffset = display1.xOffset = display.xOffset = Std.int((width-20)/2);
		display2.yOffset = display1.yOffset = display.yOffset = Std.int((height-20)/2);
	}

}
