package;

enum abstract EmitterType(Int) from Int to Int {
	var SUNRAYS;
	var SPIRAL;
	var SHOWER;
}

@:forward abstract Formula( Map<EmitterType, EmitterProgram.Params> ) {
	public var length(get, never):Int;
	inline function get_length():Int return Lambda.count(this);

	public function new() {
		this = [
			SUNRAYS => {
				fx: "ex + t*sx * cos(a)",
			 	fy: "ey + t*sy * sin(a)",
			 	
				fa: "random(seed, -1.0, 1.0) * PI" // angle
			},
			SPIRAL => {
				fx: "ex + t*sx * cos(a)",
			 	fy: "ey + t*sy * sin(a)",
			 	
				fa: "random(seed, -1.0, 1.0) * PI - t*2.0" // angle
			},
			SHOWER => {
				fx: "ex + t*(sx + random(seed, -75.0, 75.0))",
				fy: "ey + (t < 1.0 / 2.75 ? 7.5625 * t * t : t < 2.0 / 2.75 ? 7.5625 * (t - 1.5 / 2.75) * (t - 1.5 / 2.75) + 0.75 : t < 2.5 / 2.75 ? 7.5625 * (t - 2.25 / 2.75) * (t - 2.25 / 2.75) + 0.9375 : 7.5625 * (t - 2.625 / 2.75) * (t - 2.625 / 2.75) + 0.984375)*sy",
				fc: "mix(cs, ce, pow(t, 0.8))", // color
				fa: "random(seed, -1.0, 1.0) * PI - t*2.0" // angle
			}
		];
	}
	
}
