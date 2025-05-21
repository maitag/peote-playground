/**
 * The 4 relative directions
 */
enum Direction
{
	LEFT;
	RIGHT;
	UP;
	DOWN;
}





/**
 * Color util for easily setting an RGBA color from RGB integer (alpha will be maximum)
 */
abstract RGB(Int) from Int to Int
{
	inline function new(i:Int)
	{
		this = i;
	}

	@:to
	public function toRGBA():peote.view.Color
	{
		return (this << 0x08 | 0xff);
	}
}





/**
 * Returns a random int within a range
 * @param min the minimum number of the range
 * @param max the maximum number of the range
 * @return Int
 */
function randomInt(?min:Float = -1, ?max:Float = 1):Int
{
	return Std.int(min + Math.random() * (max - min));
}
