
@:structInit
@:publicFields
class VertexData{
	static var size:Int = 12;
	var x:Float;
	var y:Float;
	var z:Float;
	var vertexes:Array<VertexData> = [
		{	// left
			x: -0.5,
			y: -0.5,
			z: 0.0
		},
		{	// right
			x: 0.5,
			y: -0.5,
			z: 0.0
		},
		{
			// top
			x: 0.0,
			y: 0.5,
			z: 0.0
		},
];
}
