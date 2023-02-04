package ;

@:structInit
class Vector {
	public var x:Float;
	public var y:Float;
}

@:structInit
class Line {
	public var from:Vector;
	public var to:Vector;
}



class TurboData
{

	public static function decode(json:String):Array<Line> {
		trace(json);
		// ...
		
		return null;
	}
	
	// Half, need your HELP here into:
	
/*	function parse_file_contents(json:String):Null<Data> {
		var errors = new Array<Error>();
		var data = new JsonParser<Data>(errors).fromJson(json, 'json-errors');
		if (errors.length <= 0 && data != null) {
			return data;
		}
		else{
			for (error in errors) {
				trace(error);
			}
		}
		return null;
	}
*/
	
}