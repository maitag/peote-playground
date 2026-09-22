package ui;

@:allow(ui.Control)
@:structInit class _IntValue {
	public var value(default, set):Int = 0;
	var onChange:Int->Void = null;
	inline function set_value(v:Int) {
		if (onChange!=null) onChange(v);
		return value = v;
	}
}
@:forward abstract IntValue(_IntValue) from _IntValue to _IntValue {
	public inline function new(v:Int) this = {value:v}
	@:to inline function toInt():Int return this.value;
	@:to inline function toString():String return Std.string(this.value);
	// @:from static function fromInt(v:Int):IntValue return {value:v};
	// @:from static function fromString(s:String):IntValue return {value:Std.parseInt(s)};
}

@:allow(ui.Control)
@:structInit class _FloatValue {
	public var value(default, set):Float = 0.0;
	var onChange:Float->Void = null;
	inline function set_value(v:Float) {
		if (onChange!=null) onChange(v);
		return value = v;
	}
}
@:forward abstract FloatValue(_FloatValue) from _FloatValue to _FloatValue {
	public inline function new(v:Float) this = {value:v}
	@:to inline function toFloat():Float return this.value;
	@:to inline function toString():String return Std.string(this.value);
	// @:from static function fromFloat(v:Float):FloatValue return {value:v};
	// @:from static function fromString(s:String):FloatValue return {value:Std.parseFloat(s)};
}

@:allow(ui.Control)
@:structInit class _BoolValue {
	public var value(default, set):Bool = false;
	var onChange:Bool->Void = null;
	inline function set_value(v:Bool) {
		if (onChange!=null) onChange(v);
		return value = v;
	}
}
@:forward abstract BoolValue(_BoolValue) from _BoolValue to _BoolValue {
	public inline function new(v:Bool) this = {value:v}
	@:to inline function toBool():Bool return this.value;
	@:to inline function toString():String return Std.string(this.value);
	// @:from static function fromFloat(v:Float):FloatValue return {value:v};
	// @:from static function fromString(s:String):FloatValue return {value:Std.parseFloat(s)};
}

@:allow(ui.Control)
@:structInit class _StringValue {
	public var value(default, set):String = "";
	var onChange:String->Void = null;
	inline function set_value(v:String) {
		if (onChange!=null) onChange(v);
		return value = v;
	}
}
@:forward abstract StringValue(_StringValue) from _StringValue to _StringValue {
	public inline function new(v:String) this = {value:v}
	@:to inline function toString():String return this.value;
	// @:from static function fromFloat(v:Float):FloatValue return {value:v};
}
