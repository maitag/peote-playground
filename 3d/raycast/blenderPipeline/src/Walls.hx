import peote.view.intern.Util;
import peote.view.*;
import util.Quad;

/**
 * Renders tiled texture as vertical striped sub-tiles
 */
class Walls
{
	var tileSize:Int;
	var quads:QuadRingBuffer;

	public function new(numStripes:Int, ?texData:TextureData, ?tileTexture:Texture, tileSize:Int, wallHeight:Float)
	{
		// stripeWidth is the width of each "sub" tile
		static var stripeWidth = 1;
		this.tileSize = tileSize;
		quads = new QuadRingBuffer(numStripes, texData, tileTexture, stripeWidth, tileSize);

		// small formula to preserve texture tiling on the y axis
		// without this the tile is stretched to the height of the element
		var yOffset = Util.toFloatString(wallHeight);
		var yTileRepeat = 'tint * getTextureColor(default_ID, vec2(vTexCoord.x, fract(vTexCoord.y * $yOffset + (1.0 - mod($yOffset, 1.0)))))';
		quads.program.setColorFormula(yTileRepeat);
	}

	public function addToDisplay(display:Display)
	{
		quads.program.addToDisplay(display);
	}

	public function drawStripe(x:Int, y:Float, width:Int, height:Float, stripeIndex:Int, tileIndex:Int, fallOff:Float)
	{
		var stripe = quads.get();
		stripe.x = x;
		stripe.y = y;
		stripe.height = Std.int(height);
		stripe.width = Std.int(width);
		stripe.tile = stripeIndex + (tileIndex * tileSize);
		stripe.tint = 0xffffffFF;
		stripe.tint.valueHSV = fallOff;
		quads.updateElement(stripe);
	}

	public function update()
	{
		quads.update();
	}
}
