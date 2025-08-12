package;

enum abstract EmitterType(Int) from Int to Int {
	var SUNRAYS;
	var SPIRAL;
}

@:forward abstract Formula( Map<EmitterType, EmitterProgram.Params> ) {
	public function new() {
		this = [
			SUNRAYS => {
				fx: "ex + t*sx * cos(a)",
			 	fy: "ey + t*sy * sin(a)",
			 	
				fa: "seed"
			}
			// SPIRAL  => {fx:"", fy:""}
		];
	}
}
