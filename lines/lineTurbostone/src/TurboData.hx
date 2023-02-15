package ;

import json2object.JsonParser;

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
	public static function decode(json:String, filepath:String = "json file"):Array<Line> {
		var parser = new JsonParser<DataFile>();
		var data = parser.fromJson(json, filepath);
		
		// json2object errorhandling
		if (parser.errors.length > 0) {
			for (e in parser.errors) {
				var pos = switch (e) {case IncorrectType(_, _, pos) | IncorrectEnumValue(_, _, pos) | InvalidEnumConstructor(_, _, pos) | UninitializedVariable(_, pos) | UnknownVariable(_, pos) | ParserError(_, pos) | CustomFunctionException(_, pos): pos;}
				if (pos != null) haxe.Log.trace(json2object.ErrorUtils.convertError(e), {fileName:pos.file, lineNumber:pos.lines[0].number,className:"",methodName:""});
			}
			throw ('TurboData.hx: Error into json-format of: $filepath');
		}
		
		return data.lines;
	}	
}

class TurboTranslate 
{
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