package;

import peote.view.*;

class ProgramNormal extends Program
{
	public function new(buffer:Buffer<ElementTentacle>, normalDepthTexture:Texture)
	{	
		super(buffer);
		
		setTexture(normalDepthTexture, "normalDepth", false);
		
		injectIntoFragmentShader(
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
				
		setColorFormula( "normalDepthAlpha(normalDepth, depth)" );

		zIndexEnabled= true;
		blendEnabled = false;
	}

}
