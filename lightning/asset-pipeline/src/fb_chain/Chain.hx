package fb_chain;

import peote.view.*;
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
	public function new(peoteView:PeoteView, x:Int, y:Int, w:Int, h:Int, 
		bufferElem:Buffer<Elem>, bufferLight:Buffer<ElemLight>,
		normalDepthTexture:Texture, uvAoAlphaTexture:Texture, haxeUVTexture:Texture)
	{	
		super(x, y, w, h); // na S U P E R *lol
		

			//-------------------------------------------------
			//           Framebuffer chain  
			//-------------------------------------------------

			// --- render all tentacles uv-mapped, ao-prelightned with alpha and in depth ---
			var uvAoAlphaDepthFB = new FB_UvAoAlphaDepth(512, 512, bufferElem, normalDepthTexture, uvAoAlphaTexture, haxeUVTexture);
			uvAoAlphaDepthFB.addToPeoteView(peoteView);
			
			// ------ render all normals together to use for lightning -------
			var normalDepthFB = new FB_NormalDepth(512, 512, bufferElem, normalDepthTexture);
			normalDepthFB.addToPeoteView(peoteView);

			// ------ render all lights while using normalDepthFB texture -----
			var lightFB = new FB_Light(512, 512, bufferLight, normalDepthFB.fbTexture);
			lightFB.addToPeoteView(peoteView);







		// c i n / cout -> COMBINING ;:) ~

		var buffer = new Buffer<ChainElement>(1);			
		var program = new Program(buffer);

		program.blendEnabled = true;

		program.setTexture(uvAoAlphaDepthFB.fbTexture, "uvAoAlpha", false);
		program.setTexture(lightFB.fbTexture, "light", false);
		program.setColorFormula( "vec4( vec3(uvAoAlpha/1.5 + light/1.5), uvAoAlpha.a)");
				
		addProgram(program);

		buffer.addElement(new ChainElement(w, h));
	}

}
