package ;

import json2object.JsonParser;
import json2object.Error;

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

@:structInit
class DataFile {
	public var lines:Array<Line>;
}

class TurboData
{

	public static function decode(json:String):Array<Line> {
		trace(json);
		var errors = new Array<Error>();
		var data = new JsonParser<DataFile>(errors).fromJson(json, 'json-errors');
		if (errors.length <= 0 && data != null) {
			return data.lines;
		}
		else{
			for (error in errors) {
				trace(error);
			}
		}
		return null;
	}
	
}

class TurboTranslate{
	public static function model_to_view_point(point_in_model:Vector, view_size:Int, view_x_center:Int, view_y_center:Int):Vector {
		var transformed_point:Vector = {
			x: point_in_model.x * view_size,
			y: point_in_model.y * view_size
		}
	
		var offset_point:Vector = {
			x: transformed_point.x + view_size + view_x_center,
			y: transformed_point.y + view_size + view_y_center
		}
	
		return offset_point;
	}
}