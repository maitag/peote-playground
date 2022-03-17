package;

@:enum
abstract PenchangeMode(Int) from Int to Int {

	var _WIDTH  =  1;
	var _HEIGHT =  2;  
	var _RED    =  4;
	var _GREEN  =  8;
	var _BLUE   = 16;
	var _ALPHA  = 32;

	public var ANY(get, never):Bool;
	inline function get_ANY() return (this > 0);

	public var WIDTH(get, set):Bool;
	public inline function WIDTH_ON() this |= _WIDTH;
	public inline function WIDTH_OFF() this -= this & _WIDTH;
	inline function get_WIDTH() return (this & _WIDTH > 0);
	inline function set_WIDTH(v) { if (v) WIDTH_ON() else WIDTH_OFF(); return v; }

	public var HEIGHT(get, set):Bool;
	public inline function HEIGHT_ON() this |= _HEIGHT;
	public inline function HEIGHT_OFF() this -= this & _HEIGHT;
	inline function get_HEIGHT() return (this & _HEIGHT > 0);
	inline function set_HEIGHT(v) { if (v) HEIGHT_ON() else HEIGHT_OFF(); return v; }

	public var RED(get, set):Bool;
	public inline function RED_ON() this |= _RED;
	public inline function RED_OFF() this -= this & _RED;
	inline function get_RED() return (this & _RED > 0);
	inline function set_RED(v) { if (v) RED_ON() else RED_OFF(); return v; }

	public var GREEN(get, set):Bool;
	public inline function GREEN_ON() this |= _GREEN;
	public inline function GREEN_OFF() this -= this & _GREEN;
	inline function get_GREEN() return (this & _GREEN > 0);
	inline function set_GREEN(v) { if (v) GREEN_ON() else GREEN_OFF(); return v; }

	public var BLUE(get, set):Bool;
	public inline function BLUE_ON() this |= _BLUE;
	public inline function BLUE_OFF() this -= this & _BLUE;
	inline function get_BLUE() return (this & _BLUE > 0);
	inline function set_BLUE(v) { if (v) BLUE_ON() else BLUE_OFF(); return v; }

	public var ALPHA(get, set):Bool;
	public inline function ALPHA_ON() this |= _ALPHA;
	public inline function ALPHA_OFF() this -= this & _ALPHA;
	inline function get_ALPHA() return (this & _ALPHA > 0);
	inline function set_ALPHA(v) { if (v) ALPHA_ON() else ALPHA_OFF(); return v; }

}
