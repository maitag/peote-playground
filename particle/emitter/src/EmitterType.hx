package;

enum abstract EmitterType(Int) from Int to Int {
	var SUNRAYS;
	var SPIRAL;
}

@:forward abstract Formula( Map<EmitterType, EmitterProgram.Params> ) {
	public function new() {
		this = [
			SUNRAYS => {
				fx: "ex + mod((uTime)*300.0, 150.0) * cos(0.0)",
			 	fy: "ey + mod((uTime)*300.0, 150.0) * sin(0.0)",
				
			}
			// SPIRAL  => {fx:"", fy:""}
		];
	}
}
