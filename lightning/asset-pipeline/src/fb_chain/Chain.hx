package fb_chain;

import peote.view.*;
import peote.view.intern.BufferInterface;

import fb_chain.light.*;

class ChainElement implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX @const public var x:Int = 0;
	@posY @const public var y:Int = 0;
	
	// size in pixel
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	public function new(w:Int, h:Int) {
		this.w = w;
		this.h = h;
	}
}

// anyway -> here i am also need another broom *lol
class Chain extends Display
{
	// lightning Displays
	public var uvAoAlphaDepthFB:FB_UvAoAlphaDepth;
	public var normalDepthFB:FB_NormalDepth;
	public var lightFB:FB_Light;

	// lightning FB-Textures
	public var uvAoAlphaDepth:Texture;
	public var normalDepth:Texture;
	public var light:Texture;
	
	public function new(peoteView:PeoteView, x:Int, y:Int, w:Int, h:Int, 
		bufferElem:BufferInterface, bufferLight:BufferInterface,
		normalDepthTexture:Texture, uvAoAlphaTexture:Texture, haxeUVTexture:Texture)
	{	
		super(x, y, w, h); // na S U P E R *lol
		
		//-------------------------------------------------
		//                 LIGHTNING
		//-------------------------------------------------

		// --- render all tentacles uv-mapped, ao-prelightned with alpha and in depth ---
		uvAoAlphaDepthFB = new FB_UvAoAlphaDepth(w, h, bufferElem, normalDepthTexture, uvAoAlphaTexture, haxeUVTexture);
		uvAoAlphaDepth = new Texture(w, h, 1, {format:TextureFormat.RGB, smoothExpand: false, smoothShrink: false, powerOfTwo: false} );
		
		// ------ render all normals together to use for lightning -------
		normalDepthFB = new FB_NormalDepth(w, h, bufferElem, normalDepthTexture);
		normalDepth = new Texture(w, h, 1, {format:TextureFormat.FLOAT_RGBA, smoothExpand: false, smoothShrink: false, powerOfTwo: false} );

		// ------ render all lights while using normalDepthFB texture -----
		lightFB = new FB_Light(w, h, bufferLight, normalDepth);
		light = new Texture(w, h, 1, {format:TextureFormat.RGB, smoothExpand: false, smoothShrink: false, powerOfTwo: false} );


		//-------------------------------------------------
		//                 COMBINE  
		//-------------------------------------------------

		var buffer = new Buffer<ChainElement>(1);			
		var program = new Program(buffer);

		program.blendEnabled = true;

		program.setTexture(uvAoAlphaDepth, "uvAoAlphaDepth", false);
		program.setTexture(light, "light", false);
		program.setColorFormula( "vec4( vec3(uvAoAlphaDepth/1.5 + light/1.5), uvAoAlphaDepth.a)");
				
		addProgram(program);

		buffer.addElement(new ChainElement(w, h));
	}

	// ------------- add remove fb displays -----------------------

	override function addToPeoteView(peoteView:PeoteView, ?atDisplay:Display, addBefore:Bool=false)
	{
		uvAoAlphaDepthFB.setFramebuffer(uvAoAlphaDepth, peoteView);
		uvAoAlphaDepthFB.addToPeoteViewFramebuffer(peoteView);

		normalDepthFB.setFramebuffer(normalDepth, peoteView);
		normalDepthFB.addToPeoteViewFramebuffer(peoteView);

		lightFB.setFramebuffer(light, peoteView);
		lightFB.addToPeoteViewFramebuffer(peoteView);

		super.addToPeoteView(peoteView, atDisplay, addBefore);
	}
	
	override function removeFromPeoteView(peoteView:PeoteView)
	{
		super.removeFromPeoteView(peoteView);
		
		uvAoAlphaDepthFB.removeFromPeoteViewFramebuffer(peoteView);
		uvAoAlphaDepthFB.removeFramebuffer();

		normalDepthFB.removeFromPeoteViewFramebuffer(peoteView);
		normalDepthFB.removeFramebuffer();

		lightFB.removeFromPeoteViewFramebuffer(peoteView);
		lightFB.removeFramebuffer();		
	}
	
}
