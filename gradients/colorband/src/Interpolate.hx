package;

@:structInit 
class InterpolateImpl {
	public var start:Float = 0.0;
	public var end:Float = 0.0;
}

@:forward
abstract Interpolate(InterpolateImpl) from InterpolateImpl to InterpolateImpl {
	
	inline function new(start:Float, end:Float) {
		this = {start:start, end:end};
	}

	public static var LINEAR:Interpolate = 0.0;
	public static var SMOOTH:Interpolate = 1.0;
	
	@:from static public function fromFloat(f:Float) {
		return new Interpolate(f, f);
	}
	
}