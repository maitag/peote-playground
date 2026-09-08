package asset;

interface Tile {
	public var sheet(get, never):Int;
	public function anim<T:Int>(id:T):Anim;
	public var animID(default, never):Array<Int>;
}