package;

class Config {
	
	static var defaultHost = "localhost";
	static var defaultPort = "7680";
	static var defaultChannel = "chatplayground";

	public static var host(get,never):String;
	public static var port(get,never):Int;
	public static var channel(get,never):String;

	static function get_host() return parseDefine( haxe.macro.Compiler.getDefine("host"), defaultHost, checkHost );   
	static function get_port() return Std.parseInt(parseDefine( haxe.macro.Compiler.getDefine("port"), defaultPort, checkPort ));   
	static function get_channel() return parseDefine( haxe.macro.Compiler.getDefine("channel"), defaultChannel, checkChannel );   
	

	static function parseDefine(v:String, defaultValue:String, check:String->Bool):String {
		if (v == null) return defaultValue;
		if (v.substr(v.length>>1, 1) == "=") v = v.substr((v.length>>1)+1);
		return check(v) ? v : defaultValue;
	}
	
	static function checkHost(v:String):Bool {
		if (~/^(\d{1,3}\.){3}\d{1,3}$/.match(v)) return true;
		if (~/^[a-z0-9][a-z0-9-]*$/.match(v)) return true;
		if (~/^([a-z0-9][a-z0-9-]*\.)+[a-z]+$/.match(v)) return true;
		return false;
	}

	static function checkPort(v:String):Bool {
		if (! ~/^\d{1,5}$/.match(v)) return false;
		if (Std.parseInt(v)>65535) return false;
		return true;
	}

	public static function checkChannel(v:String):Bool {
		if (~/^[a-zA-Z0-9][a-zA-Z0-9-_.]*$/.match(v)) return true;
		return false;
	}

}