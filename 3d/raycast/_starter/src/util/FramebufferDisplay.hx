package util;

import peote.view.*;
import util.Quad;

/**
 * This fancy Display renders to a texture. 
 */
class FramebufferDisplay extends Display
{
	public var fbo(default, null):QuadBuffer;

	var frame:Quad;

	public function new(peoteView:PeoteView, width:Int, height:Int, color:Color = 0x00000000)
	{
		super(0, 0, width, height, color);

		// tell peote view to use this display as a framebuffer
		peoteView.addFramebufferDisplay(this);

		// set a texture that the framebuffer will be rendered to
		setFramebuffer(new Texture(width, height));

		// buffer/program/element for rendering the texture
		fbo = new QuadBuffer(1);
		fbo.program.addTexture(fbTexture);
		frame = fbo.addElement(new Quad(width, height, false));
	}
}
