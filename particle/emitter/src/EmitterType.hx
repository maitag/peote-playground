package;

enum abstract EmitterType(Int) from Int to Int {
	var SUNRAYS;
	var SPIRAL;
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
			}
		];
	}
	
}
