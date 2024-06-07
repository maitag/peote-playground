package fb_light;

import peote.view.*;
import peote.view.intern.BufferInterface;

@:forward(x, y, width, height)
abstract NormalDepthFB(Display) to Display
{
	public function new(w:Int, h:Int, buffer:BufferInterface, normalDepthTexture:Texture)
	{	
		this = new Display(0, 0, w, h);
		
		var program = new Program(buffer);
		
		program.setTexture(normalDepthTexture, "normalDepth", false);
		
		program.injectIntoFragmentShader(
			"	
			vec2 rotate(vec2 v, float a) {
				float s = sin(a);
				float c = cos(a);
				mat2 m = mat2(-c, -s, s, -c);
				// mat2 m = mat2(c, -s, s, c);
				return m * v;
			}

			vec4 normalDepthAlpha( vec4 normalDepthTex, float depth)
			{
				// flip x normal (depends on uv-map generation variants)
				// normalDepthTex.r = 1.0 - normalDepthTex.r;
				
				vec3 N;

				// z-buffer
				if (normalDepthTex.a < 1.0)
				{
					gl_FragDepth = ( normalDepthTex.a / 3.0 + depth);

					// normalize and rotate vector
					N = normalize(normalDepthTex.xyz * 2.0 - 1.0);
					N.xy = rotate(N.xy, vRotZ.x);
				}
				else gl_FragDepth =  1.0; 


				// return vec4(N.x, N.y, N.z, normalDepthTex.a);
				return vec4(N.x, N.y, N.z, gl_FragDepth);
			}
		");
				
		program.setColorFormula( "normalDepthAlpha(normalDepth, depth)" );
		
		program.zIndexEnabled= true;
		program.blendEnabled = false;
		
		this.addProgram(program);
	}

	public inline function addToPeoteView(peoteView:PeoteView, ?atDisplay:Display, addBefore:Bool=false)
	{
		if (texture == null) this.setFramebuffer(new Texture(this.width, this.height, 1, {format:TextureFormat.FLOAT_RGBA, smoothExpand: false, smoothShrink: false} ), peoteView);
		this.addToPeoteViewFramebuffer(peoteView, atDisplay, addBefore);
	}

	public inline function removeFromPeoteView(peoteView:PeoteView) this.removeFromPeoteViewFramebuffer(peoteView);
	
	public var texture(get, never):Texture;
	@:access(peote.view.Display) inline function get_texture():Texture return this.fbTexture;
}
