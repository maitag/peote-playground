package asset;

@:structInit @:publicFields class Anim {
	var start:Int;
	var end:Int;
	public inline function new(s:Int, e:Int) {
		start = s;
		end = e;
	}
}
