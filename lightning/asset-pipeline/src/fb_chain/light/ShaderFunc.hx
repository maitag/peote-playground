package fb_chain.light;

@:publicFields
class ShaderFunc
{
	static var rotate = "
		
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
	";

}
