import peote.view.*;

@:publicFields
class TileWave implements Element {
	/**
		position on x axis
	**/
	@posX var x:Int;

	/**
		position on y axis
	**/
	@posY @formula("z + y + wave(phase) * amp") var y:Int;
	@custom @varying var z:Float = 0.0;
	@custom @varying var phase:Float = 1.0;
	@custom @varying var amp:Float = 1.0;

	public static var fragment:String = '
	float wave(float phase)
	{
		float freq = (2.0 * 3.142) / u_leng;
		float sine = sin(freq + uTime + phase) + sin((freq * 2.0) + uTime + phase / 2.0);
		return sine * u_amp;
	}
	';

	/**
		width in pixels
	**/
	@sizeX var width:Int;

	/**
		height in pixels
	**/
	@sizeY var height:Int;

	/**
	 * tile index in the texture
	 */
	@texTile var tile:Int;

	/**
	 * what RGBA color to tint the tile
	 */
	@color var tint:Color = 0xffffffFF;

	var OPTIONS = {blend: true};

	function new(x:Float = 0, y:Float = 0, width:Float, height:Float, tile:Int) {
		this.x = Std.int(x);
		this.y = Std.int(y);
		this.width = Std.int(width);
		this.height = Std.int(height);
		this.tile = tile;
	}
}
