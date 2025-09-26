package render.fb_light;

import peote.view.*;
import peote.view.intern.BufferInterface;

@:forward(width, height, fbTexture)
abstract NormalDepthFB(Display) to Display
{
	public function new(w:Int, h:Int, buffer:BufferInterface, normalDepthTexture:Texture)
	{	
		this = new Display(0, 0, w, h);
		
		var program = new Program(buffer);
		
		program.setTexture(normalDepthTexture, "normalDepth", false);
		
		program.injectIntoFragmentShader(
		"	
			vec4 normalDepthAlpha( vec4 normalDepthTex)
			{
				// flip x normal (depends on uv-map generation variants)
				// normalDepthTex.r = 1.0 - normalDepthTex.r;
				// normalDepthTex.g = 1.0 - normalDepthTex.g;
				// normalDepthTex.b = 1.0 - normalDepthTex.b;
				
				// z-buffer
				// if (normalDepthTex.a < 1.0) {
					// gl_FragDepth = normalDepthTex.a;
				// }
				// else gl_FragDepth =  1.0; 
				gl_FragDepth = normalDepthTex.a;

				return normalDepthTex;
				// return vec4(normalDepthTex.rgb, gl_FragDepth);
			}
		");
				
		program.setColorFormula( "normalDepthAlpha(normalDepth)" );
		
		program.zIndexEnabled= true;
		program.blendEnabled = false;
		
		this.addProgram(program);
	}

	public inline function addToPeoteView(peoteView:PeoteView, ?atDisplay:Display, addBefore:Bool=false)
	{
		if (this.fbTexture == null) this.setFramebuffer(new Texture(this.width, this.height, 1, {format:TextureFormat.RGBA, smoothExpand: false, smoothShrink: false, powerOfTwo: false} ), peoteView);
		this.addToPeoteViewFramebuffer(peoteView, atDisplay, addBefore);
	}

	public inline function removeFromPeoteView(peoteView:PeoteView) this.removeFromPeoteViewFramebuffer(peoteView);
}
