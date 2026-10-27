package fb_chain;

import peote.view.*;
import peote.view.intern.BufferInterface;
import peote.view.intern.Util;

import fb_chain.light.*;

class ChainElement implements Element
{
	@sizeX @const public var w:Int;
	@sizeY @const public var h:Int;
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
		normalDepthTextures:Array<Texture>, uvAoAlphaTextures:Array<Texture>, haxeUVTexture:Texture,
		useFloatNormalPass=false, usePackedNormals=false)
	{	
		super(x, y, w, h); // na S U P E R *lol
		
		//-------------------------------------------------
		//                 LIGHTNING
		//-------------------------------------------------

		// --- render uv-mapped, ao-prelightned with alpha and in depth ---
		uvAoAlphaDepthFB = new FB_UvAoAlphaDepth(w, h, bufferElem, normalDepthTextures, uvAoAlphaTextures, haxeUVTexture, usePackedNormals);
		uvAoAlphaDepth = new Texture(w, h, 1, {format:TextureFormat.RGB, smoothExpand: false, smoothShrink: false, powerOfTwo: false} );
		
		// ------ render normals together to use for lightning -------
		normalDepthFB = new FB_NormalDepth(w, h, bufferElem, normalDepthTextures, useFloatNormalPass, usePackedNormals);
		normalDepth = new Texture(w, h, 1, {
				format:(useFloatNormalPass) ? TextureFormat.FLOAT_RGBA : TextureFormat.RGBA,
				smoothExpand: false,
				smoothShrink: false,
				powerOfTwo: false
		});

		// ------ render lights while using normalDepthFB texture -----
		lightFB = new FB_Light(w, h, bufferLight, normalDepth, useFloatNormalPass);
		light = new Texture(w, h, 1, {format:TextureFormat.RGB, smoothExpand: false, smoothShrink: false, powerOfTwo: false} );


		//-------------------------------------------------
		//                 COMBINE  
		//-------------------------------------------------

		var buffer = new Buffer<ChainElement>(1);			
		var program = new Program(buffer);

		program.blendEnabled = true;

		program.setFormula("w", Util.toFloatString(w), false);
		program.setFormula("h", Util.toFloatString(h), false);
		program.setTexture(uvAoAlphaDepth, "uvAoAlphaDepth", false);
		program.setTexture(light, "light", false);
	
		program.setColorFormula( "vec4( vec3(uvAoAlphaDepth/1.5 + light/1.5), uvAoAlphaDepth.a)");
		// program.setColorFormula( "vec4( vec3(light), 1.0)");
		
		// program.setTexture(normalDepthTextures[0], "normalDepth", false);
		// program.setTexture(normalDepth, "normalDepth", false);
		// program.setColorFormula("normalDepth");
				
		addProgram(program);

		buffer.addElement(new ChainElement());
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

	public var xOffset_FB(get,set):Float;
	function get_xOffset_FB():Float return uvAoAlphaDepthFB.xOffset;
	function set_xOffset_FB(v:Float) return uvAoAlphaDepthFB.xOffset = normalDepthFB.xOffset = lightFB.xOffset = v;

	public var yOffset_FB(get,set):Float;
	function get_yOffset_FB():Float return uvAoAlphaDepthFB.yOffset;
	function set_yOffset_FB(v:Float) return uvAoAlphaDepthFB.yOffset = normalDepthFB.yOffset = lightFB.yOffset = v;

	public var zoom_FB(get,set):Float;
	function get_zoom_FB():Float return uvAoAlphaDepthFB.zoom;
	function set_zoom_FB(v:Float) return uvAoAlphaDepthFB.zoom = normalDepthFB.zoom = lightFB.zoom = v;

	public function zoomAt(mouse_x:Float, mouse_y:Float, deltaY:Float, zoomstep:Float, min:Float=0.25, max:Float=20) {
		if ( deltaY > 0) {
			if (zoom_FB >= max) return;
			xOffset_FB -= zoomstep * (mouse_x - xOffset_FB) - (mouse_x - xOffset_FB);
			yOffset_FB -= zoomstep * (mouse_y - yOffset_FB) - (mouse_y - yOffset_FB);
			zoom_FB *= zoomstep;
		}
		else {
			if (zoom_FB <= min) return;
			xOffset_FB -= (mouse_x - xOffset_FB) / zoomstep - (mouse_x - xOffset_FB);
			yOffset_FB -= (mouse_y - yOffset_FB) / zoomstep - (mouse_y - yOffset_FB);
			zoom_FB /= zoomstep;
		}
	}

	public function localX_FB(x:Float):Float return uvAoAlphaDepthFB.localX(localX(x));
	public function localY_FB(y:Float):Float return uvAoAlphaDepthFB.localY(localY(y));

	public function pickElement_FB(x:Float, y:Float):Int {
		return peoteView.getElementAt( localX(x), localY(y), uvAoAlphaDepthFB, uvAoAlphaDepthFB.iterator().next());
	}
	
}
