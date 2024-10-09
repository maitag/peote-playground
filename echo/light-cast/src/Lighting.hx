import peote.view.Element;
import peote.view.Color;

@:publicFields
@:structInit
class Lighting implements Element
{
	@posX var x: Int;
	@posY var y: Int;
	@sizeX @varying var width: Int;
	@sizeY @varying var height: Int;
	@custom @varying var ray_origin_x: Float = 0.0;
	@custom @varying var ray_origin_y: Float = 0.0;
	@color var darkness:Color = 0x000000ff;

	function new(x: Int, y: Int, width: Int, height: Int)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
}