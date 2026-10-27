package fb_chain.light;

@:publicFields
class ShaderFunc
{
	static var rotate = "
		
		vec2 rotate(vec2 v, float a) {
			float s = sin(a);
			float c = cos(a);
			mat2 m = mat2(c, s, -s, c);
			return m * v;
		}
			
		vec3 rotateX(vec3 v, float angleDegrees) {
			float angleRad = radians(angleDegrees);
			float c = cos(angleRad);
			float s = sin(angleRad);
			mat3 m = mat3(
				1.0, 0.0, 0.0,
				0.0,   c,  -s,
				0.0,   s,   c
			);
			return m * v;
		}
		
		vec3 rotateY(vec3 v, float angleDegrees) {
			float angleRad = radians(angleDegrees);
			float c = cos(angleRad);
			float s = sin(angleRad);
			mat3 m = mat3(
				c, 0.0,   s,
				0.0, 1.0, 0.0,
				-s, 0.0,   c
			);
			return m * v;
		}
		
		vec3 rotateZ(vec3 v, float angleDegrees) {
			float angleRad = radians(angleDegrees);
			float c = cos(angleRad);
			float s = sin(angleRad);
			mat3 m = mat3(
				c,  -s, 0.0,
				s,   c, 0.0,
				0.0, 0.0, 1.0
			);
			return m * v;
		}

		vec3 debugNormale(vec3 N) {
			N = rotateX(N, u_debug_rotate.x);
			N = rotateY(N, u_debug_rotate.y);
			N = rotateZ(N, u_debug_rotate.z);
			
			if (u_debug_swap==1) N.xyz = N.xzy;
			if (u_debug_swap==2) N.xyz = N.yxz;
			if (u_debug_swap==3) N.xyz = N.yzx;
			if (u_debug_swap==4) N.xyz = N.zxy;
			if (u_debug_swap==5) N.xyz = N.zyx;
			
			if (u_debug_invert.x==1) N.x=-N.x;
			if (u_debug_invert.y==1) N.y=-N.y;
			if (u_debug_invert.z==1) N.z=-N.z;

			// N = normalize(N); // <----- is NEED for OVERNORMALIZATION ? lol^^
			return N;
		}
	";

}
